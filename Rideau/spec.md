# Rideau Gesture and Motion Spec

This spec defines how Rideau coordinates sheet gestures with an inner
`UIScrollView`, and how Rideau should behave when the sheet is dragged beyond
its valid range. The implementation should follow this spec.

## 1. Terms

- **Sheet**: The drawer shown by Rideau (`containerView`).
- **Snap point**: A position the sheet can settle into. Snap points are declared
  in `RideauView.Configuration.snapPoints` and resolved internally into
  `ResolvedSnapPoint` values ordered from top to bottom.
  - **Top snap point** = `resolvedSnapPoints.first`, the most expanded position.
  - **Bottom-most visible snap point** = the lowest non-hidden snap point.
  - **Hidden** = the special snap point where the sheet is fully off-screen.
- **Hiding offset**: The `constant` of the bottom constraint attached to the
  sheet. A larger value means the sheet is positioned farther down.
- **Inner scroll view**: A `UIScrollView` inside the sheet content. The
  submodule auto-detects one through the responder chain and tracks at most one
  scroll view at a time.
- **Outer drag**: The gesture that directly moves the sheet itself.
- **`isScrollLockEnabled`**: A flag exposed by the submodule. While it is `true`,
  the submodule pins the inner scroll view's `contentOffset` through KVO and
  routes all translation into the outer drag.
- **Top edge of the scroll view**: The state where
  `scrollableEdges.contains(.top) == false`, meaning the scroll view is already
  scrolled all the way to the top. This is evaluated by the submodule.

## 2. Gesture Responsibilities

**Rideau side**

- Determine whether the sheet is currently at the top snap point.
- Toggle `panGesture.isScrollLockEnabled` accordingly.
- Drive snap transitions and animations from the translation and velocity
  received in `handleDragChange` and `handleDragEnd`.

**Submodule side**

Configuration:
`edgeActivationMode: .onlyAtGestureStart`, `targetEdges: .top`,
`sticksToEdges: true`, `minimumActivationDistance: 15`

- Consume movement smaller than 15 pt and do not forward it to Rideau.
- While `isScrollLockEnabled == true`, fully lock the inner scroll view and send
  all translation to the outer drag.
- While `isScrollLockEnabled == false`, activate the outer drag only if the
  scroll view was already at the target edge when the gesture started. A
  gesture that starts from mid-content remains owned by the inner scroll view
  until that gesture ends.
- Cancel in-flight deceleration when the scroll view becomes locked, and cancel
  deferred deceleration again when the lock is released.
- Hide the scroll indicator while locked and restore it when the gesture ends.

## 3. Gesture and Motion Rules

### 3.1 When the Gesture Starts at a Non-Top Snap Point

- Rideau sets `isScrollLockEnabled = true` and keeps it true for the beginning
  of the gesture.
- Dragging upward moves the sheet upward.
- Dragging downward moves the sheet downward toward a lower snap point or
  `.hidden`.
- Once the sheet reaches the top snap point during that gesture, Rideau may
  switch `isScrollLockEnabled` to `false`.
  - Result: after reaching the top snap point from a middle snap point, the
    user can keep dragging upward in the same gesture and the inner scroll view
    can take over scrolling.
  - However, `.onlyAtGestureStart` still uses the scroll state captured at the
    beginning of the gesture. Whether a later downward drag can reactivate the
    outer drag still depends on the scroll state at gesture start.

### 3.2 When the Gesture Starts at the Top Snap Point

Rideau keeps `isScrollLockEnabled = false` for the whole gesture. The actual
ownership is decided by the submodule using `.onlyAtGestureStart`.

#### 3.2.1 The Scroll View Was Already at the Top Edge at Gesture Start

- Upward drag: the submodule does not activate the outer drag. With
  `targetEdges = .top`, upward movement corresponds to the `.bottom` edge, which
  is outside the configured target edges. The scroll view stays pinned at the
  top and its own `bounces` behavior handles the overscroll effect.
- Downward drag: the submodule activates the outer drag because
  `scrollableEdges.contains(.top) == false &&
  initialScrollableEdges.contains(.top) == false`.
  The sheet moves downward.

#### 3.2.2 The Scroll View Was Below the Top Edge at Gesture Start

- `initialScrollableEdges.contains(.top) == true`, so with
  `.onlyAtGestureStart` the outer drag is never activated for that gesture.
- Upward drag scrolls the inner scroll view.
- Downward drag also stays inside the inner scroll view. Even after the scroll
  view reaches its top edge, the sheet does not move and only the scroll view's
  own bounce behavior appears.
- To move the sheet downward from this state, the user must release and start a
  new gesture.

### 3.3 Horizontal Motion and Other Edges

- `targetEdges: .top`. No coordination is performed for the bottom edge.
- Horizontal scrolling should always remain free and must not be locked.

### 3.4 The 15 pt Gate

- The 15 pt threshold is owned entirely by the submodule through
  `minimumActivationDistance: 15`.
- Rideau should not apply its own additional gate. Once `onChange` fires,
  Rideau can assume the user has already moved at least 15 pt.

### 3.5 External Gestures via `register(other:)`

- Input coming from an external `UIPanGestureRecognizer` does not go through the
  submodule. It is forwarded directly into `handleDragChange` and
  `handleDragEnd`.
- The inner scroll view is not involved on this path, so the scroll-lock flag
  is irrelevant. This path behaves like Section 3.1.

## 4. Snap Resolution on Gesture End

- Final position `nextPosition`:
  - `between(range)`:
    - if `|vy| <= |vx|`, snap to the nearer snap point
    - if `|vy| <= 400`, snap to the nearer snap point
    - if `vy < -400`, snap to `range.start` (the upper snap point)
    - if `vy > 400`, snap to `range.end` (the lower snap point)
  - `exact`, `outOfStart`, and `outOfEnd` resolve to the corresponding snap
    point directly
- If `target == .hidden`, further input is rejected by setting
  `isTerminated = true`.
- Animations use `UIViewPropertyAnimator` with `UISpringTimingParameters`.
  Damping, response, and velocity calculations differ depending on whether
  `resizeToVisibleArea` is enabled.

## 5. Out-of-Range Behavior (Rubber Band)

- The rubber-band formula uses
  `FluidGroup/swift-rubber-banding`'s
  `rubberBand(value:min:max:bandLength:)`.
  - `f(x) = L * (1 - 1 / (x * 0.55 / L + 1))`, which uses the same 0.55 factor
    as UIKit.
  - The old frame-by-frame linear attenuation based on
    `deltaTranslation * 0.1` is removed. The new model is based on absolute
    cumulative translation since the gesture started.
- Rubber banding applies at both the top snap point and the bottom-most visible
  snap point.
- Transitions toward `.hidden` are not rubber-banded and should follow the snap
  rules from Section 4.
- The visual effect is applied by stretching `containerViewHeightConstraint`
  while clamping the hiding offset to the nearest snap point.

  Pseudocode:

  ```swift
  let nearest = (outOfStart) ? topSnap : bottomSnap
  let overshoot = nextHidingOffset - nearest.hidingOffset
  let banded = rubberBand(
    value: Double(overshoot),
    min: 0,
    max: 0,
    bandLength: 20
  )
  containerViewBottomConstraint.constant = nearest.hidingOffset
  containerViewHeightConstraint.constant =
    resolvedState.maximumContainerViewHeight - CGFloat(banded)
  containerView.updateLayoutGuideBottomOffset(0)
  ```

- `bandLength = 20` is fixed. This matches the height rubber band used in
  swiftui-blanket and keeps the maximum stretch visually tight while still
  making the boundary feel obvious.
- This Rideau-side rubber band should appear only while
  `isScrollLockEnabled == true` or while the submodule currently owns the outer
  drag. While the inner scroll view owns the gesture, such as the whole of
  Section 3.2.2 and the upward path in Section 3.2.1, the scroll view's own
  `bounces` behavior is responsible for the overscroll effect. Rideau must not
  apply a second rubber band on top of that.

## 6. Required Submodule Features

- dynamic switching of `isScrollLockEnabled`
- configurable `targetEdges`
- `edgeActivationMode: .onlyAtGestureStart`
- configurable `minimumActivationDistance`
- deceleration cancellation when locking and unlocking
- scroll-indicator hiding while locked

Minimum version:
`swiftui-scrollview-interoperable-drag-gesture` `0.4.0`

## 7. Acceptance Tests

Verify these in `RideauDemo` with both SwiftUI and UIKit content:

- **T1** (Section 3.1): Start from a middle snap point and drag upward. The
  sheet moves to the top snap point. The scroll view does not move.
- **T2** (Section 3.1): Start from a middle snap point and drag downward. The
  sheet moves toward a lower snap point or `.hidden`.
- **T3** (Section 3.1, reaching the top): Start from a middle snap point and
  drag upward aggressively until the sheet reaches the top snap point. Without
  releasing, keep dragging upward. The inner scroll view should take over and
  scroll.
- **T4** (Section 3.2.1): Start at the top snap point with the inner scroll
  view already at its top edge. Drag upward. The sheet does not move and the
  scroll view's own bounce behavior appears.
- **T5** (Section 3.2.1): Start at the top snap point with the inner scroll
  view already at its top edge. Drag downward. The sheet moves downward.
- **T6** (Section 3.2.1, direction reversal): From T5, reverse direction
  upward without releasing. The sheet moves back upward. Because of
  `sticksToEdges`, the scroll view stays effectively locked while the outer drag
  owns the gesture. After the sheet reaches the top snap point, continued
  upward drag returns control to the inner scroll view.
- **T7** (Section 3.2.2): Start at the top snap point while the inner scroll
  view is scrolled somewhere in the middle. Drag downward. The inner scroll
  view scrolls internally. Even after it reaches the top edge, the sheet does
  not move and only the scroll view's bounce behavior appears.
- **T8** (Section 3.2.2, short drag): In the same setup as T7, release before
  the inner scroll view reaches its top edge. The sheet does not move.
- **T9** (Section 3.4): A jiggle smaller than 15 pt should not move the sheet
  or the scroll view, and should not trigger locking.
- **T10a** (Section 5): From the top snap point, pull further upward strongly.
  The resistance should feel like `UIScrollView` bounce, increasing
  non-linearly, and should spring back on release.
- **T10b** (Section 5): From the bottom-most visible snap point, pull downward
  strongly. The same rubber-band behavior should appear symmetrically and
  spring back on release.
- **T10c** (Section 5, repeatability): Repeating the same drag translation
  should produce nearly the same visual position each time.
- **T11** (deceleration fix): Flick the inner scroll view strongly and, while
  it is decelerating, grab the sheet and drag downward. The deceleration should
  stop immediately and the sheet should follow the finger.
