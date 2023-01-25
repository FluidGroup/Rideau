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

  private let panGesture = RideauViewDragGestureRecognizer()

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

      panGesture.addTarget(self, action: #selector(handlePan))
      panGesture.delegate = self
      containerView.addGestureRecognizer(panGesture)
    }

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
    setNeedsLayout()
    layoutIfNeeded()
  }

  /**
   Registers other panGesture to enable dragging outside view.
   */
  func register(other panGesture: UIPanGestureRecognizer) {
    panGesture.addTarget(self, action: #selector(handlePan))
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

      if #available(iOS 11, *) {
        prepareAlongsideAnimators()
      }

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

  @objc private dynamic func handlePan(gesture: UIPanGestureRecognizer) {
    guard self.isTerminated == false else { return }

    func currentHidingOffset() -> CGFloat {

      let offset = actualTopMargin

      var nextValue: CGFloat
      if let v = containerView.layer.presentation().map({ $0.frame.origin.y }) {
        nextValue = v
      } else {
        nextValue = containerView.frame.origin.y
      }

      nextValue -= offset

      return nextValue
    }

    func makeNextHidingOffset(translation: CGPoint) -> CGFloat {
      var nextValue = currentHidingOffset()
      nextValue += translation.y
      return nextValue
    }

    guard let resolvedState = resolvedState else {
      assertionFailure()
      return
    }

    let translation = gesture.translation(in: gesture.view!)

    defer {
      gesture.setTranslation(.zero, in: gesture.view!)
    }

    let currentHidingOffset = currentHidingOffset()
    let nextPosition = resolvedState.currentPosition(from: makeNextHidingOffset(translation: translation))

    Log.debug(.pan, nextPosition)

    let locationInWindow = gesture.location(in: gesture.view?.window)

    let isReachingToMostExpandablePoint = resolvedState.isReachingToMostExpandablePoint(hidingOffset: currentHidingOffset)

    switch gesture.state {
    case .began:

      began: do {

        trackingState = .init(
          beganHidingOffset: currentHidingOffset,
          beganPoint: locationInWindow
        )

        guard let trackingState = self.trackingState else {
          fatalError()
        }

        isInteracting = true

        containerDraggingAnimator?.pauseAnimation()
        containerDraggingAnimator?.stopAnimation(true)

        if #available(iOS 11, *) {
          prepareAlongsideAnimators()
        }

        let targetScrollView: UIScrollView? = {

          guard let gesture = gesture as? RideauViewDragGestureRecognizer else {
            // it's possible when touched outside of Rideau.
            return nil
          }

          switch configuration.scrollViewOption.scrollViewDetection {
          case .noTracking: return nil
          case .automatic: return gesture.trackingScrollView
          case .specific(let scrollView): return scrollView
          }
        }()

        if let scrollView = targetScrollView {
          Log.debug(.pan, "Found scrollview, contentOffset: \(scrollView.contentOffset)")
          trackingState.scrollViewState = .init(
            trackingScrollView: scrollView,
            scrollController: .init(scrollView: scrollView),
            lastScrollViewContentOffset: scrollView.contentOffset,
            initialShowsVerticalScrollIndicator: scrollView.showsVerticalScrollIndicator,
            initialIsScrollingDown: scrollView.isScrollingDown()
          )
          trackingState.scrollViewState!.scrollController.lockScrolling()
        }

      }

      fallthrough
    case .changed:

      changed: do {
        guard let trackingState = self.trackingState else {
          assertionFailure("trackingState must be created in `began`.")
          return
        }

        throttlingGesture_run: do {
          if trackingState.isPanGestureTracking == false, abs(trackingState.beganPointInWindow.y - locationInWindow.y) < 15 {
            Log.debug(.pan, "Tracking idling...")
            return
          } else {
            #if DEBUG
            if trackingState.isPanGestureTracking == false {
              Log.debug(.pan, "Tracking started")
            }
            #endif
            trackingState.isPanGestureTracking = true
          }
        }

        if trackingState.hasEverReachedMostTop == false {
          trackingState.hasEverReachedMostTop = isReachingToMostExpandablePoint
        }

        let skipsDraggingContainer: Bool

        if let scrollViewState = trackingState.scrollViewState {

          let scrollView = scrollViewState.trackingScrollView

          let panDirection: PanDirection = gesture.translation(in: gesture.view).y > 0 ? .down : .up

          @inline(__always)
          func unlockScrolling() {
            scrollViewState.scrollController.unlockScrolling()
            scrollViewState.scrollController.setShowsVerticalScrollIndicator(scrollViewState.initialShowsVerticalScrollIndicator)
          }

          switch panDirection {
          case .down:

            if configuration.scrollViewOption.allowsBouncing {

              if trackingState.hasEverReachedMostTop {

                if scrollViewState.initialIsScrollingDown {
                  /**
                   blocking moving container
                   */
                  unlockScrolling()
                  skipsDraggingContainer = true
                } else {

                  Log.debug(.scrollView, scrollView.isScrollingToTop(includiesRubberBanding: true))

                  if scrollView.isScrollingToTop(includiesRubberBanding: true) {
                    scrollViewState.scrollController.lockScrolling()
                    scrollViewState.scrollController.resetContentOffsetY()
                    scrollViewState.scrollController.setShowsVerticalScrollIndicator(false)
                    skipsDraggingContainer = false
                  } else {
                    unlockScrolling()
                    skipsDraggingContainer = true
                  }

                }

              } else {

                scrollViewState.scrollController.lockScrolling()
                skipsDraggingContainer = false
              }

            } else {
              if trackingState.hasEverReachedMostTop {

                if scrollView.isScrollingToTop(includiesRubberBanding: true) {
                  scrollViewState.scrollController.lockScrolling()
                  scrollViewState.scrollController.resetContentOffsetY()
                  scrollViewState.scrollController.setShowsVerticalScrollIndicator(false)
                  skipsDraggingContainer = false
                } else {
                  unlockScrolling()
                  skipsDraggingContainer = true
                }
              } else {

                scrollViewState.scrollController.lockScrolling()
                scrollViewState.scrollController.setShowsVerticalScrollIndicator(false)
                skipsDraggingContainer = false
              }

            }
          case .up:

            if isReachingToMostExpandablePoint {
              scrollViewState.lastScrollViewContentOffset = scrollView.contentOffset
              unlockScrolling()

              skipsDraggingContainer = true
            } else {

              scrollViewState.scrollController.lockScrolling()
              scrollViewState.scrollController.setShowsVerticalScrollIndicator(false)

              skipsDraggingContainer = false
            }
          }

          scrollViewState.lastScrollViewContentOffset = scrollView.contentOffset
        } else {
          skipsDraggingContainer = false
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

        if skipsDraggingContainer == false {

          draggingContainer: do {

            switch nextPosition.cased {
            case .exact:
              updateConstraints(hidingOffset: nextPosition.hidingOffset)
            case .between(let range):
              updateConstraints(hidingOffset: nextPosition.hidingOffset)
              if #available(iOS 11, *) {

                let fractionCompleteInRange = ValuePatch(nextPosition.hidingOffset)
                  .progress(
                    start: range.start.hidingOffset,
                    end: range.end.hidingOffset
                  )
                  .clip(min: 0, max: 1)
                  .reverse()
                  .fractionCompleted

                animatorStore[range]?.forEach {
                  $0.isReversed = false
                  $0.pauseAnimation()
                  $0.fractionComplete = fractionCompleteInRange
                }

                animatorStore
                  .filter { $0.start > range.start }
                  .forEach {
                    $0.isReversed = false
                    $0.pauseAnimation()
                    $0.fractionComplete = 1
                  }

                animatorStore
                  .filter { $0.end < range.start }
                  .forEach {
                    $0.isReversed = false
                    $0.pauseAnimation()
                    $0.fractionComplete = 0
                  }

              }

            case .outOfStart(let point), .outOfEnd(let point):
              containerViewBottomConstraint.constant = point.hidingOffset
              let offset = translation.y * 0.1
              /** rubber-banding */
              containerViewHeightConstraint.constant -= offset
              containerView.updateLayoutGuideBottomOffset(0)
            }

          }
        } else {

          /// putting back the position of the container which dragged position halfway

          let currentPosition = resolvedState.currentPosition(from: currentHidingOffset)
          let snapPointToFix: ResolvedSnapPoint = {
            switch currentPosition.cased {
            case .between(let range):
              return range.pointCloser(by: nextPosition.hidingOffset)!
            case .exact(let snapPoint),
              .outOfEnd(let snapPoint),
              .outOfStart(let snapPoint):
              return snapPoint
            }
          }()

          updateConstraints(hidingOffset: snapPointToFix.hidingOffset)
        }
      }

    case .ended, .cancelled, .failed:

      end: do {

        guard let trackingState = self.trackingState else {
          return
        }

        guard trackingState.isPanGestureTracking else {
          return
        }

        if let scrollViewState = trackingState.scrollViewState {

          let scrollController = scrollViewState.scrollController

          let isLocking = scrollController.isLocking
          let scrollView = scrollController.scrollView
          scrollController.endTracking()

          if isLocking {

            // To perform task next event loop.
            DispatchQueue.main.async {
              Log.debug(.scrollView, "Kill scroll decelaration")
              UIView.performWithoutAnimation {
                var targetOffset = scrollViewState.lastScrollViewContentOffset
                let insetTop = _getActualContentInset(from: scrollView).top
                if targetOffset.y < -insetTop {
                  // Workaround: sometimes, scrolling-lock may be failed. ContentOffset has a little bit negative offset.
                  targetOffset.y = -insetTop
                }
                scrollView.setContentOffset(targetOffset, animated: false)
                scrollView.showsVerticalScrollIndicator = scrollViewState.initialShowsVerticalScrollIndicator
                scrollView.layoutIfNeeded()
              }
            }
          }

        }

        let gestureVelocity = gesture.velocity(in: gesture.view!)

        let target: ResolvedSnapPoint = {

          switch nextPosition.cased {
          case .between(let range):

            guard let pointCloser = range.pointCloser(by: nextPosition.hidingOffset) else {
              fatalError()
            }

            let threshold: CGFloat = 400

            guard abs(gestureVelocity.y) > abs(gestureVelocity.x) else {
              Log.debug(.pan, "Stay velocity.x is bigger")
              return pointCloser
            }

            switch gestureVelocity.y {
            case -threshold...threshold:
              Log.debug(.pan, "Stay")
              // stay in current snappoint
              return pointCloser
            case ...(-threshold):
              Log.debug(.pan, "Move to start")
              return range.start
            case threshold...:
              Log.debug(.pan, "Move to end")
              return range.end
            default:
              fatalError()
            }

          case .exact(let snapPoint),
            .outOfEnd(let snapPoint),
            .outOfStart(let snapPoint):
            Log.debug(.pan, "No need to move")
            return snapPoint
          }
        }()

        Log.debug(.pan, "Decides final snap point \(target)")

        let proposedVelocity: CGVector = {

          let targetTranslateY = target.hidingOffset

          Log.debug(.animation, "gestureVelociy: \(gestureVelocity), target: \(targetTranslateY), from: \(nextPosition.hidingOffset)")

          var initialVelocity = CGVector(
            dx: 0,
            dy: abs(abs(gestureVelocity.y) / (targetTranslateY - nextPosition.hidingOffset))
          )

          if initialVelocity.dy.isInfinite || initialVelocity.dy.isNaN {
            Log.debug(.animation, "Calculation failed isInfinite: \(initialVelocity.dy.isInfinite), isNan: \(initialVelocity.dy.isNaN)")
            initialVelocity.dy = 0
          }

          if case .outOfStart = nextPosition.cased {
            return .zero
          }

          if case .outOfEnd = nextPosition.cased {
            return .zero
          }

          return initialVelocity
        }()

        continueInteractiveTransition(
          target: target,
          velocity: proposedVelocity,
          resolvedState: resolvedState,
          completion: {

          }
        )

        if target.source == .hidden {
          self.isTerminated = true
        }
      }
    default:
      break
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

  private enum PanDirection {
    case up
    case down
  }

  private struct CachedValueSet: Equatable {

    var sizeThatLastUpdated: CGSize
    var offsetThatLastUpdated: CGFloat
    var usingConfiguration: RideauView.Configuration
  }

  private final class TrackingState {

    final class ScrollViewState {

      let trackingScrollView: UIScrollView
      let scrollController: ScrollController
      // To tracking pan gesture
      var lastScrollViewContentOffset: CGPoint
      let initialShowsVerticalScrollIndicator: Bool
      var initialIsScrollingDown: Bool

      internal init(
        trackingScrollView: UIScrollView,
        scrollController: ScrollController,
        lastScrollViewContentOffset: CGPoint,
        initialShowsVerticalScrollIndicator: Bool,
        initialIsScrollingDown: Bool
      ) {
        self.trackingScrollView = trackingScrollView
        self.scrollController = scrollController
        self.lastScrollViewContentOffset = lastScrollViewContentOffset
        self.initialShowsVerticalScrollIndicator = initialShowsVerticalScrollIndicator
        self.initialIsScrollingDown = initialIsScrollingDown
      }
    }

    /// instantiates if found a scrollview.
    var scrollViewState: ScrollViewState?

    var hasEverReachedMostTop: Bool = false

    var isPanGestureTracking = false

    let beganHidingOffset: CGFloat

    /// a point in the window that started by the gesture
    let beganPointInWindow: CGPoint

    init(
      beganHidingOffset: CGFloat,
      beganPoint: CGPoint
    ) {
      self.beganPointInWindow = beganPoint
      self.beganHidingOffset = beganHidingOffset
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

    /**
     A representation of current position in relation to snap-points.
     */
    struct Position {

      enum CasedPosition {
        case between(ResolvedSnapPointRange)
        case exact(ResolvedSnapPoint)

        /// crossing over maximum expandable snap-point.
        case outOfEnd(ResolvedSnapPoint)
        /// crossing over minimum expandable snap-point.
        case outOfStart(ResolvedSnapPoint)
      }

      var hidingOffset: CGFloat
      var cased: CasedPosition
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

    func currentPosition(from hidingOffset: CGFloat) -> Position {

      if let point = resolvedSnapPoints.first(where: { $0.hidingOffset == hidingOffset }) {
        return .init(hidingOffset: hidingOffset, cased: .exact(point))
      }

      precondition(!resolvedSnapPoints.isEmpty)

      let firstHalf = resolvedSnapPoints.lazy.filter { $0.hidingOffset <= hidingOffset }
      let secondHalf = resolvedSnapPoints.lazy.filter { $0.hidingOffset >= hidingOffset }

      if !firstHalf.isEmpty && !secondHalf.isEmpty {

        return .init(hidingOffset: hidingOffset, cased: .between(ResolvedSnapPointRange(firstHalf.last!, secondHalf.first!)))
      }

      if firstHalf.isEmpty {
        return .init(hidingOffset: hidingOffset, cased: .outOfEnd(secondHalf.first!))
      }

      if secondHalf.isEmpty {
        return .init(hidingOffset: hidingOffset, cased: .outOfStart(firstHalf.last!))
      }

      fatalError("Unexpected")

    }

    func smallestVisibleSnappoint() -> ResolvedSnapPoint {
      resolvedSnapPoints.filter { $0.source != .hidden }.last!
    }

  }
}

extension RideauHostingView: UIGestureRecognizerDelegate {

  @objc
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

    guard let _gestureRecognizer = gestureRecognizer as? RideauViewDragGestureRecognizer else {
      assertionFailure("\(gestureRecognizer)")
      return false
    }
    
    guard !(otherGestureRecognizer is UIScreenEdgePanGestureRecognizer) else {
      return false
    }

    switch configuration.scrollViewOption.scrollViewDetection {
    case .noTracking:
      return false
    case .automatic:
      let result = _gestureRecognizer.trackingScrollView == otherGestureRecognizer.view
      return result
    case .specific(let scrollView):
      return otherGestureRecognizer.view == scrollView
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

extension UIScrollView {

  func isScrollingToTop(includiesRubberBanding: Bool) -> Bool {
    if includiesRubberBanding {
      return contentOffset.y <= -actualContentInset.top
    } else {
      return contentOffset.y == -actualContentInset.top
    }
  }

  func isScrollingDown() -> Bool {
    return contentOffset.y > -actualContentInset.top
  }

  var contentOffsetToResetY: CGPoint {
    let contentInset = _getActualContentInset(from: self)
    var contentOffset = contentOffset
    contentOffset.y = -contentInset.top
    return contentOffset
  }

  @inline(__always)
  var actualContentInset: UIEdgeInsets {
    if #available(iOS 11, *) {
      return adjustedContentInset
    } else {
      return contentInset
    }
  }

}
