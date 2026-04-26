//
// Rideau
//
// Copyright © 2019 Hiroshi Kimura
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import SwiftUIScrollViewInteroperableDragGesture
import RubberBanding

/// A view that manages ``RideauContentContainerView``
final class RideauHostingView: RideauTouchThroughView {

  /// A set of closures that tell events that happen on RideauInternalView.
  struct InternalHandlers {

    /// Tells the snap point will change to another snap point.
    ///
    /// - Warning: RideauInternalView will not always move to the destination snap point. If the user interrupted moving animation, didChangeSnapPoint brings another snap point up to you.
    var willChangeSnapPoint: (_ destination: RideauSnapPoint) -> Void = { _ in }

    /// Tells the new snap point that currently RidauView snaps.
    var didChangeSnapPoint: (_ destination: RideauSnapPoint) -> Void = { _ in }
  }

  // MARK: - Properties

  var parentView: RideauView? {
    return superview.map {
      $0 as! RideauView
    }
  }

  var handlers: RideauView.Handlers = .init()

  weak var delegate: RideauViewDelegate?

  /// A set of handlers for inter-view communication.
  internal var internalHandlers: InternalHandlers = .init()

  internal let backdropView = RideauTouchThroughView()

  private var actualTopMargin: CGFloat {
    switch configuration.topMarginOption {
    case .fromTop(let value):
      return value
    case .fromSafeArea(let value):
      let offset: CGFloat
      if #available(iOS 11.0, *) {
        offset = safeAreaInsets.top + value
      } else {
        offset = 20 + value
      }
      return offset
    }
  }

  /**
   A height constraints for RideauContentContainerView.
   the constant would be set as maximum expandable size.
   */
  private var containerViewHeightConstraint: NSLayoutConstraint!

  /**
   A bottom constraints to hide the container view by offset
   */
  private var containerViewBottomConstraint: NSLayoutConstraint!

  /**
   A view that hosts a content and sliding by dragging and programaticaly.
   */
  public let containerView = RideauContentContainerView()

  private(set) public var configuration: RideauView.Configuration

  /**
   It would be set on layoutSubviews.
   */
  private var resolvedState: ResolvedState?

  private var trackingState: TrackingState?

  private var containerDraggingAnimator: UIViewPropertyAnimator?

  private var animatorStore: AnimatorStore = .init()

  private var currentSnapPoint: ResolvedSnapPoint?

  /// a latest value that has been delivered over the delegate
  private var propagatedSnapPoint: ResolvedSnapPoint?

  private var isInteracting: Bool = false

  private var isTerminated: Bool = false

  private var shouldUpdateLayout: Bool = false

  private var oldValueSet: CachedValueSet?

  private var hasTakenAlongsideAnimators: Bool = false

  private let panGesture = UIScrollViewInteroperableDragGestureRecognizer(
    configuration: .init(
      ignoresScrollView: false,
      targetEdges: .top,
      sticksToEdges: true,
      edgeActivationMode: .onlyAtGestureStart,
      minimumActivationDistance: 15
    )
  )

  // MARK: - Initializers

  init(
    frame: CGRect,
    configuration: RideauView.Configuration
  ) {

    self.configuration = configuration
    super.init(frame: .zero)

  }

  // MARK: - Functions

  func setup() {

    callback: do {

      containerView.didChangeContent = { [weak self] animator in
        guard let self = self else { return }
        guard self.isInteracting == false else { return }
        // It needs to update update resolvedState
        self.shouldUpdateLayout = true

        if let animator = animator {
          assert(animator.state == .inactive)
          animator.addAnimations {
            self.setNeedsLayout()
            self.layoutIfNeeded()
          }
          animator.startAnimation()
        } else {
          self.setNeedsLayout()
          self.layoutIfNeeded()
        }

      }
    }

    view: do {

      containerView.translatesAutoresizingMaskIntoConstraints = false

      addSubview(backdropView)
      backdropView.frame = bounds
      backdropView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

      addSubview(containerView)
      containerView.setOwner(self)
      containerView.setObservesIntrinsicContentSizeInvalidations(
        configuration.snapPoints.contains(.autoPointsFromBottom)
      )

      containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 0).setIdentifier("maximum-height")
      containerViewHeightConstraint.priority = .required

      containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).setIdentifier("hiding-offset")

      NSLayoutConstraint.activate([
        containerViewBottomConstraint,
        containerViewHeightConstraint,
        containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
        containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
      ])

    }

    gesture: do {

      panGesture.coordinateSpaceView = containerView
      panGesture.onChange = { [weak self] value in
        self?.handleDragChange(value: value)
      }
      panGesture.onEnd = { [weak self] value in
        self?.handleDragEnd(value: value)
      }
      containerView.addGestureRecognizer(panGesture)
      applyGestureConfiguration()
    }

  }

  private func applyGestureConfiguration() {
    let ignoresScrollView: Bool
    switch configuration.scrollViewOption.scrollViewDetection {
    case .noTracking:
      ignoresScrollView = true
    case .automatic:
      ignoresScrollView = false
    }
    panGesture.configuration = .init(
      ignoresScrollView: ignoresScrollView,
      targetEdges: .top,
      sticksToEdges: true,
      edgeActivationMode: .onlyAtGestureStart,
      minimumActivationDistance: 15
    )
  }

  @available(*, unavailable)
  required init?(
    coder aDecoder: NSCoder
  ) {
    fatalError()
  }

  deinit {

    animatorStore
      .allAnimators()
      .forEach {
        $0.stopAnimation(true)
      }
  }

  // MARK: - Functions

  func update(configuration: RideauView.Configuration) {
    self.configuration = configuration
    containerView.setObservesIntrinsicContentSizeInvalidations(
      configuration.snapPoints.contains(.autoPointsFromBottom)
    )
    applyGestureConfiguration()
    setNeedsLayout()
    layoutIfNeeded()
  }

  private func resolve(configuration: RideauView.Configuration) -> ResolvedState {

    let maxHeight = self.bounds.height - actualTopMargin

    let points = configuration.snapPoints.map { snapPoint -> ResolvedSnapPoint in
      switch snapPoint {
      case .hidden:
        return .init(pointsFromTop: round(maxHeight - -8), source: snapPoint)
      case .fraction(let fraction):
        return .init(pointsFromTop: round(maxHeight - maxHeight * fraction), source: snapPoint)
      case .pointsFromTop(let points):
        return .init(pointsFromTop: points, source: snapPoint)
      case .pointsFromBottom(let points):
        return .init(pointsFromTop: round(maxHeight - points), source: snapPoint)
      case .autoPointsFromBottom:

        guard let view = containerView.currentBodyView else {
          return .init(pointsFromTop: 0, source: snapPoint)
        }

        let size: CGSize = {

          let targetSize = CGSize(
            width: bounds.width,
            height: UIView.layoutFittingCompressedSize.height
          )

          let horizontalPriority: UILayoutPriority = .required
          let verticalPriority: UILayoutPriority = .fittingSizeLevel

          func _markNeedsLayoutRecursively(view: UIView) {

            for view in view.subviews {
              view.setNeedsLayout()
              _markNeedsLayoutRecursively(view: view)
            }

          }

          /// to propagate safeAreaInsets before sizing view
          do {
            _markNeedsLayoutRecursively(view: view)
            view.layoutIfNeeded()
          }

          return view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalPriority,
            verticalFittingPriority: verticalPriority
          )
        }()

        return .init(
          pointsFromTop: min(maxHeight, max(0, maxHeight - size.height)),
          source: snapPoint
        )
      }
    }

    let configuration = ResolvedState(
      snapPoints: points,
      maximumContainerViewHeight: maxHeight
    )

    containerViewHeightConstraint.constant = maxHeight

    return configuration
  }

  override func layoutSubviews() {

    super.layoutSubviews()

    let valueSet = CachedValueSet(
      sizeThatLastUpdated: bounds.size,
      offsetThatLastUpdated: actualTopMargin,
      usingConfiguration: configuration
    )

    guard oldValueSet != nil else {

      // First time layout

      oldValueSet = valueSet

      shouldUpdateLayout = false

      let newresolvedState = resolve(configuration: self.configuration)
      resolvedState = newresolvedState

      hasTakenAlongsideAnimators = false
      prepareAlongsideAnimators()

      if let initial = newresolvedState.resolvedSnapPoints.last {
        updateLayout(target: initial, resolvedState: newresolvedState)
      } else {
        assertionFailure()
      }

      return
    }

    guard shouldUpdateLayout || oldValueSet != valueSet, let currentSnapPoint = currentSnapPoint else {
      // No needs to update layout
      return
    }

    oldValueSet = valueSet
    shouldUpdateLayout = false

    let newresolvedState = resolve(configuration: configuration)

    guard resolvedState != newresolvedState else {
      // It had to update layout, but configuration for layot does not have changes.
      return
    }

    resolvedState = newresolvedState

    hasTakenAlongsideAnimators = false
    prepareAlongsideAnimators()

    guard
      let snapPoint = newresolvedState.resolvedSnapPoint(by: currentSnapPoint.source) ?? newresolvedState.resolvedSnapPoints.first
    else {
      // ??? probably, not need to update current layout
      return
    }

    updateLayout(target: snapPoint, resolvedState: newresolvedState)

  }

  func move(to snapPoint: RideauSnapPoint, animated: Bool, completion: @escaping () -> Void) {

    guard let resolvedState = resolvedState else {
      assertionFailure()
      return
    }

    preventCurrentAnimations: do {

      animatorStore.allAnimators()
        .forEach {
          $0.pauseAnimation()
        }

      containerDraggingAnimator?.stopAnimation(true)
    }

    guard let target = resolvedState.resolvedSnapPoints.first(where: { $0.source == snapPoint }) else {
      assertionFailure("No such snap point")
      return
    }

    if animated {
      continueInteractiveTransition(
        target: target,
        velocity: .zero,
        resolvedState: resolvedState,
        completion: completion
      )
    } else {
      UIView.performWithoutAnimation {
        continueInteractiveTransition(
          target: target,
          velocity: .zero,
          resolvedState: resolvedState,
          completion: completion
        )
      }
    }

  }

  @available(iOS 11, *)
  private func prepareAlongsideAnimators() {

    if !hasTakenAlongsideAnimators {

      hasTakenAlongsideAnimators = true

      resolvedState?
        .ranges()
        .forEach { range in

          let animators: [UIViewPropertyAnimator]
          if let handler = handlers.animatorsAlongsideMoving {
            animators = handler(range)
          } else {
            animators = delegate?.rideauView(parentView!, animatorsAlongsideMovingIn: range) ?? []
          }

          animators.forEach { animator in
            animator.pausesOnCompletion = true
            animator.pauseAnimation()
            animatorStore.set(animator: animator, for: range)
          }
        }
    }

  }

  private func currentHidingOffset() -> CGFloat {

    let offset = actualTopMargin.rounded()

    var nextValue: CGFloat
    if let v = containerView.layer.presentation().map({ $0.frame.origin.y }) {
      nextValue = v
    } else {
      nextValue = containerView.frame.origin.y
    }

    nextValue.round()

    nextValue -= offset

    return nextValue
  }

  private func handleDragChange(value: ScrollViewInteroperableDragGestureValue) {
    guard self.isTerminated == false else { return }

    guard let resolvedState = resolvedState else {
      assertionFailure()
      return
    }

    if trackingState == nil {
      // First event of a new gesture — equivalent to the old `.began` branch.
      containerDraggingAnimator?.pauseAnimation()
      containerDraggingAnimator?.stopAnimation(true)
      let beganHidingOffset = currentHidingOffset()
      let beganIsAtTopSnap = resolvedState.isReachingToMostExpandablePoint(hidingOffset: beganHidingOffset)
      trackingState = .init(
        beganHidingOffset: beganHidingOffset,
        beganIsAtTopSnap: beganIsAtTopSnap
      )
      panGesture.isScrollLockEnabled = !beganIsAtTopSnap
      isInteracting = true
    }

    guard let trackingState = self.trackingState else {
      assertionFailure()
      return
    }

    let nextHidingOffset = trackingState.beganHidingOffset + value.translation.height
    let snapRange = resolvedState.snapRange(for: nextHidingOffset)

    Log.debug(.pan, snapRange)

    // spec §3.2.1 reversal — when the gesture started at top snap, the sheet
    // went below, and now returns to top snap, clear the submodule's sticky
    // edge state so the inner scroll view regains control for subsequent pans.
    // Requires the `stickingEdges` API from submodule PR #9.
    if trackingState.beganIsAtTopSnap,
      resolvedState.isReachingToMostExpandablePoint(hidingOffset: nextHidingOffset),
      panGesture.stickingEdges.isEmpty == false
    {
      panGesture.stickingEdges = []
    }

    if trackingState.beganIsAtTopSnap == false {
      // A drag that started from a lower snap should own the sheet until it
      // reaches the top snap. Once there, hand control back to the inner
      // scroll view so continuing the same upward drag can scroll content.
      panGesture.isScrollLockEnabled =
        resolvedState.isReachingToMostExpandablePoint(hidingOffset: nextHidingOffset) == false
    }

    func updateConstraints(hidingOffset: CGFloat) {
      let bottomOffset: CGFloat
      if resolvedState.smallestVisibleSnappoint().hidingOffset < hidingOffset {
        bottomOffset = hidingOffset - resolvedState.smallestVisibleSnappoint().hidingOffset
      } else {
        bottomOffset = 0
      }

      containerView.updateLayoutGuideBottomOffset(bottomOffset)

      containerViewBottomConstraint.constant = hidingOffset
      containerViewHeightConstraint.constant = resolvedState.maximumContainerViewHeight
    }

    switch (snapRange.lower, snapRange.higher) {
    case (let lower?, let higher?):
      updateConstraints(hidingOffset: nextHidingOffset)

      // Exactly on a snap point — no interpolation needed.
      guard lower != higher else { break }

      let animatorRange = ResolvedSnapPointRange(lower, higher)
      let fractionCompleteInRange = ValuePatch(nextHidingOffset)
        .progress(start: lower.hidingOffset, end: higher.hidingOffset)
        .clip(min: 0, max: 1)
        .reverse()
        .fractionCompleted

      animatorStore[animatorRange]?.forEach {
        $0.isReversed = false
        $0.pauseAnimation()
        $0.fractionComplete = fractionCompleteInRange
      }

      animatorStore
        .filter { $0.start > animatorRange.start }
        .forEach {
          $0.isReversed = false
          $0.pauseAnimation()
          $0.fractionComplete = 1
        }

      animatorStore
        .filter { $0.end < animatorRange.start }
        .forEach {
          $0.isReversed = false
          $0.pauseAnimation()
          $0.fractionComplete = 0
        }

    case (nil, let nearest?), (let nearest?, nil):
      // Out of range on either end — apply rubber-band (spec §5).
      // `swift-rubber-banding` uses the Apple 0.55 coefficient. Input is the
      // cumulative overshoot from gesture start, so the mapping is absolute
      // and frame-rate independent.
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

    case (nil, nil):
      assertionFailure("snapRange must have at least one snap point")
    }
  }

  private func handleDragEnd(value: ScrollViewInteroperableDragGestureValue) {
    guard self.isTerminated == false else {
      trackingState = nil
      return
    }

    guard let resolvedState = resolvedState else {
      trackingState = nil
      return
    }

    guard let trackingState = self.trackingState else {
      return
    }
    defer {
      self.trackingState = nil
      isInteracting = false
      // Note: `isScrollLockEnabled` is NOT reset here. The animator block in
      // `continueInteractiveTransition` calls `updateLayout`, which invokes
      // `syncScrollLockPolicy` with the final snap point — setting the flag
      // to the correct value for the sheet's new resting state.
    }

    let nextHidingOffset = trackingState.beganHidingOffset + value.translation.height
    let snapRange = resolvedState.snapRange(for: nextHidingOffset)
    let gestureVelocity = CGPoint(x: value.velocity.width, y: value.velocity.height)

    let target: ResolvedSnapPoint = {
      switch (snapRange.lower, snapRange.higher) {
      case (let lower?, let higher?):
        // Exactly on a snap point.
        guard lower != higher else {
          Log.debug(.pan, "No need to move")
          return lower
        }

        // Between two snap points — closer of the two is default, velocity
        // threshold (400) overrides to the direction the user is flicking.
        let pointCloser: ResolvedSnapPoint = {
          let lowerDistance = abs(nextHidingOffset - lower.hidingOffset)
          let higherDistance = abs(higher.hidingOffset - nextHidingOffset)
          return lowerDistance <= higherDistance ? lower : higher
        }()

        let threshold: CGFloat = 400

        guard abs(gestureVelocity.y) > abs(gestureVelocity.x) else {
          Log.debug(.pan, "Stay velocity.x is bigger")
          return pointCloser
        }

        switch gestureVelocity.y {
        case -threshold...threshold:
          Log.debug(.pan, "Stay")
          return pointCloser
        case ...(-threshold):
          Log.debug(.pan, "Move to start")
          return lower
        case threshold...:
          Log.debug(.pan, "Move to end")
          return higher
        default:
          fatalError()
        }

      case (nil, let higher?):
        Log.debug(.pan, "Out of start")
        return higher
      case (let lower?, nil):
        Log.debug(.pan, "Out of end")
        return lower
      case (nil, nil):
        fatalError("snapRange must have at least one snap point")
      }
    }()

    Log.debug(.pan, "Decides final snap point \(target)")

    let proposedVelocity: CGVector = {
      // No velocity transfer when the user overshot and the sheet must spring
      // back — preserves the previous outOfStart/outOfEnd behavior.
      let isOutOfRange = snapRange.lower == nil || snapRange.higher == nil
      if isOutOfRange {
        return .zero
      }

      let targetTranslateY = target.hidingOffset
      Log.debug(.animation, "gestureVelociy: \(gestureVelocity), target: \(targetTranslateY), from: \(nextHidingOffset)")

      var initialVelocity = CGVector(
        dx: 0,
        dy: abs(abs(gestureVelocity.y) / (targetTranslateY - nextHidingOffset))
      )

      if initialVelocity.dy.isInfinite || initialVelocity.dy.isNaN {
        Log.debug(.animation, "Calculation failed isInfinite: \(initialVelocity.dy.isInfinite), isNan: \(initialVelocity.dy.isNaN)")
        initialVelocity.dy = 0
      }

      return initialVelocity
    }()

    continueInteractiveTransition(
      target: target,
      velocity: proposedVelocity,
      resolvedState: resolvedState,
      completion: {}
    )

    if target.source == .hidden {
      self.isTerminated = true
    }
  }

  /// Update the current layout with updating the constant value of constraints.
  /// - Parameter target:
  private func updateLayout(target: ResolvedSnapPoint, resolvedState: ResolvedState) {

    currentSnapPoint = target

    containerViewBottomConstraint.constant = target.hidingOffset
    containerViewHeightConstraint.constant = resolvedState.maximumContainerViewHeight

    if target.source == .hidden {
      containerView.updateLayoutGuideBottomOffset(target.hidingOffset - resolvedState.smallestVisibleSnappoint().hidingOffset)
    } else {
      containerView.updateLayoutGuideBottomOffset(0)
    }

    // Pre-arm the scroll-lock policy based on the resting snap point so that
    // the submodule doesn't have to wait for a frame of `onChange` to learn it.
    // This matters for §3.1 (non-top snap): upward pans never trigger the
    // submodule's outer-activation branch, so if the lock is not already
    // engaged at touches-began, `onChange` never fires and the sheet can't
    // be pulled up.
    syncScrollLockPolicy(for: target, resolvedState: resolvedState)
  }

  /// Keep `panGesture.isScrollLockEnabled` aligned with whether the sheet is
  /// currently at its most-expanded snap point. Called from `updateLayout`
  /// whenever the resting snap changes.
  private func syncScrollLockPolicy(for snapPoint: ResolvedSnapPoint, resolvedState: ResolvedState) {
    let atTopSnap = resolvedState.isReachingToMostExpandablePoint(hidingOffset: snapPoint.hidingOffset)
    panGesture.isScrollLockEnabled = !atTopSnap
  }

  private func continueInteractiveTransition(
    target: ResolvedSnapPoint,
    velocity: CGVector,
    resolvedState: ResolvedState,
    completion: @escaping () -> Void
  ) {

    Log.debug(.animation, "Velocity \(velocity)")

    propagate: do {

      if currentSnapPoint != target {
        internalHandlers.willChangeSnapPoint(target.source)
        delegate?.rideauView(self.parentView!, willMoveTo: target.source)
        handlers.willMoveTo?(target.source)
      }
    }

    assert(currentSnapPoint != nil)

    let topAnimator: UIViewPropertyAnimator

    switch containerView.currentResizingOption {
    case .noResize?:

      topAnimator = UIViewPropertyAnimator(
        duration: 0.5,
        timingParameters: UISpringTimingParameters(
          dampingRatio: 0.9,
          initialVelocity: CGVector(dx: 0, dy: velocity.dy)
        )
      )

    case .resizeToVisibleArea?, .none:

      let damping = ValuePatch(velocity.dy)
        .progress(start: 0, end: 20)
        .clip(min: 0, max: 1)
        .transition(start: 1, end: 0.7)
        .value

      topAnimator = UIViewPropertyAnimator(
        duration: 0,
        timingParameters: UISpringTimingParameters(
          damping: damping,  // Workaround : Can't use initialVelocity, initialVelocity cause strange animation that will shrink and expand subviews"
          response: 0.3,
          initialVelocity: .zero
        )
      )
    }

    // flush pending updates

    layoutIfNeeded()

    if #available(iOS 11, *) {

      animatorStore
        .filter { range in
          range.start >= target
        }
        .forEach {
          $0.isReversed = false
          $0.pauseAnimation()
          if $0.fractionComplete < 1 {
            $0.continueAnimation(withTimingParameters: nil, durationFactor: 1)
          }
        }

      animatorStore
        .filter { range in
          range.end <= target
        }
        .forEach {
          $0.isReversed = true
          $0.pauseAnimation()
          if $0.fractionComplete < 1 {
            $0.continueAnimation(withTimingParameters: nil, durationFactor: 1)
          }
        }

    }

    topAnimator
      .addAnimations {
        self.updateLayout(target: target, resolvedState: resolvedState)
        self.layoutIfNeeded()
      }

    topAnimator.addCompletion { _ in

      // WARN: If topAnimator is stopped as force, this completion block will not be called.

      completion()
      propagate: do {
        if self.propagatedSnapPoint?.source != target.source {
          self.delegate?.rideauView(self.parentView!, didMoveTo: target.source)
          self.handlers.didMoveTo?(target.source)
          self.internalHandlers.didChangeSnapPoint(target.source)
          self.propagatedSnapPoint = target
        }
      }
    }

    topAnimator.startAnimation()

    #if DEBUG
    let animations = (containerView.layer.animationKeys() ?? []).compactMap {
      containerView.layer.animation(forKey: $0)
    }
    Log.debug(.animation, "animations \(animations)")
    #endif

    containerDraggingAnimator = topAnimator

  }

}

extension RideauHostingView {

  private struct CachedValueSet: Equatable {

    var sizeThatLastUpdated: CGSize
    var offsetThatLastUpdated: CGFloat
    var usingConfiguration: RideauView.Configuration
  }

  private final class TrackingState {

    let beganHidingOffset: CGFloat

    /// Whether the sheet was at the top-most snap point when the gesture began.
    /// Drags that start below the top snap keep the inner scroll view locked
    /// until the sheet reaches the top snap. Drags that start at the top snap
    /// leave ownership to the submodule for the whole gesture.
    let beganIsAtTopSnap: Bool

    init(beganHidingOffset: CGFloat, beganIsAtTopSnap: Bool) {
      self.beganHidingOffset = beganHidingOffset
      self.beganIsAtTopSnap = beganIsAtTopSnap
    }
  }

  private struct AnimatorStore {

    private var backingStore: [ResolvedSnapPointRange: [UIViewPropertyAnimator]] = [:]

    subscript(_ range: ResolvedSnapPointRange) -> [UIViewPropertyAnimator]? {
      get {
        return backingStore[range]
      }
      set {
        backingStore[range] = newValue
      }
    }

    mutating func set(animator: UIViewPropertyAnimator, for key: ResolvedSnapPointRange) {

      var array = self[key]

      if array != nil {
        array?.append(animator)
        self[key] = array
      } else {
        let array = [animator]
        self[key] = array
      }

    }

    func filter(_ condition: (ResolvedSnapPointRange) -> Bool) -> [UIViewPropertyAnimator] {
      return
        backingStore
        .filter { condition($0.key) }
        .reduce(into: [UIViewPropertyAnimator]()) { (result, args) in
          result += args.value
        }
    }

    func allAnimators() -> [UIViewPropertyAnimator] {

      return
        backingStore.reduce(into: [UIViewPropertyAnimator]()) { (result, args) in
          result += args.value
        }

    }

    mutating func removeAllAnimations() {
      backingStore.removeAll()
    }

  }

  struct ResolvedState: Equatable {

    // MARK: - Nested types

    /// Where a given hiding offset sits relative to the resolved snap points,
    /// expressed as (lower, higher) nullable pair. Inspired by blanket's
    /// `Resolved.range(for:)`.
    ///
    /// - both non-nil, equal → exactly on a snap point
    /// - both non-nil, different → between two snap points
    /// - only `higher` → above the top-most snap point (out-of-start)
    /// - only `lower` → below the bottom-most snap point (out-of-end)
    struct SnapRange: Equatable {
      let lower: ResolvedSnapPoint?
      let higher: ResolvedSnapPoint?
    }

    // MARK: - Properties

    /**
     first is most expanded snappoint
     */
    let resolvedSnapPoints: [ResolvedSnapPoint]

    let maximumContainerViewHeight: CGFloat

    // MARK: - Initializers

    init(
      snapPoints: [ResolvedSnapPoint],
      maximumContainerViewHeight: CGFloat
    ) {
      self.maximumContainerViewHeight = maximumContainerViewHeight
      self.resolvedSnapPoints = Set(snapPoints).sorted(by: <)
    }

    // MARK: - Functions

    func ranges() -> [ResolvedSnapPointRange] {

      guard resolvedSnapPoints.count >= 2 else {
        assertionFailure("")
        return []
      }

      var ranges: [ResolvedSnapPointRange] = []
      var before: ResolvedSnapPoint = resolvedSnapPoints.first!
      for point in resolvedSnapPoints.dropFirst() {
        let range = ResolvedSnapPointRange(before, point)
        ranges.append(range)
        before = point
      }

      return ranges

    }

    func isReachingToMostExpandablePoint(hidingOffset: CGFloat) -> Bool {
      resolvedSnapPoints.first!.hidingOffset >= hidingOffset
    }

    func isReachedMostTop(_ resolvedSnapPoint: ResolvedSnapPoint) -> Bool {
      return resolvedSnapPoints.first?.hidingOffset == resolvedSnapPoint.hidingOffset
    }

    func resolvedSnapPoint(by snapPoint: RideauSnapPoint) -> ResolvedSnapPoint? {
      return resolvedSnapPoints.first { $0.source == snapPoint }
    }

    /// Returns the lower/higher snap points bracketing the given hiding offset.
    /// See `SnapRange` for the four-way interpretation.
    func snapRange(for hidingOffset: CGFloat) -> SnapRange {
      precondition(!resolvedSnapPoints.isEmpty)
      let lower = resolvedSnapPoints.last { $0.hidingOffset <= hidingOffset }
      let higher = resolvedSnapPoints.first { $0.hidingOffset >= hidingOffset }
      return SnapRange(lower: lower, higher: higher)
    }

    func smallestVisibleSnappoint() -> ResolvedSnapPoint {
      resolvedSnapPoints.filter { $0.source != .hidden }.last!
    }

  }
}

extension UISpringTimingParameters {
  convenience init(
    damping: CGFloat,
    response: CGFloat,
    initialVelocity: CGVector = .zero
  ) {
    let stiffness = pow(2 * .pi / response, 2)
    let damp = 4 * .pi * damping / response
    self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
  }

  public convenience init(
    decelerationRate: CGFloat,
    frequencyResponse: CGFloat,
    initialVelocity: CGVector = .zero
  ) {
    let dampingRatio = CoreGraphics.log(decelerationRate) / (-4 * .pi * 0.001)
    self.init(damping: dampingRatio, response: frequencyResponse, initialVelocity: initialVelocity)
  }

}
