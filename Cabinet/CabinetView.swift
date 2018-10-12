//
//  CabinetView.swift
//  Cabinet
//
//  Created by muukii on 9/22/18.
//  Copyright © 2018 muukii. All rights reserved.
//

import UIKit

public protocol CabinetContentViewType : class {

  var headerView: UIView? { get }
  var bodyView: UIView? { get }
  var scrollViews: [UIScrollView] { get }
}

extension CabinetContentViewType where Self : UIView {

  public func set(state: CabinetView.State) {

    let cabinetView = superview as! CabinetView

    cabinetView.set(state: state)
  }
}

public final class CabinetView : TouchThroughView {

  public enum State : Int, Comparable {
    public static func < (lhs: CabinetView.State, rhs: CabinetView.State) -> Bool {
      return lhs.rawValue < rhs.rawValue
    }

    case closed
    case halfOpened
    case opened

  }

  private struct Config {

    private var storage : [State : CGFloat] = [:]

    func translateY(for state: State) -> CGFloat {
      return storage[state]!
    }

    mutating func setTranslateY(closed: CGFloat, opened: CGFloat, halfOpened: CGFloat) {

      assert(opened < halfOpened && halfOpened < closed)

      storage = [
        State.closed : closed,
        State.halfOpened : halfOpened,
        State.opened : opened,
      ]
    }

  }

  private var top: NSLayoutConstraint!

  private let backdropView = TouchThroughView()

  private let containerView = UIView()

  private weak var contentView: (UIView & CabinetContentViewType)?

  private var config: Config = .init()

  private var containerDraggingAnimator: UIViewPropertyAnimator?

  private var dimmingAnimator: UIViewPropertyAnimator?

  private var runningAnimatorsForHalfOpenedToOpened: [UIViewPropertyAnimator] = []
  private var runningAnimatorsForClosed: [UIViewPropertyAnimator] = []

  var currentState: State = .opened

  public override init(frame: CGRect) {
    super.init(frame: .zero)
    setup()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  public func set(state: State) {

    runningAnimatorsForHalfOpenedToOpened.forEach {
      $0.stopAnimation(true)
    }

    runningAnimatorsForHalfOpenedToOpened = []

    animateTransitionIfNeeded()
    continueInteractiveTransition(target: state, velocity: .zero)
  }

  public func set(contentView: UIView & CabinetContentViewType) {

    containerView.addSubview(contentView)
    contentView.frame = containerView.bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.contentView = contentView
  }

  private func setup() {

    containerView.translatesAutoresizingMaskIntoConstraints = false

    addSubview(backdropView)
    backdropView.frame = bounds
    backdropView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    addSubview(containerView)

    top = containerView.topAnchor.constraint(equalTo: topAnchor, constant: 64)

    let height = containerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1, constant: -44)
    height.priority = .defaultHigh

    NSLayoutConstraint.activate([
      top,
      containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
      height,
      containerView.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: 0),
      containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
      ])

    gesture: do {

      let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
      containerView.addGestureRecognizer(pan)
    }

  }

  @objc private func handlePan(gesture: UIPanGestureRecognizer) {

    switch gesture.state {
    case .began:
      animateTransitionIfNeeded()
      startInteractiveTransition()
      fallthrough
    case .changed:

      let translation = gesture.translation(in: gesture.view!)

      let nextConstant = containerView.frame.origin.y + translation.y

      if case config.translateY(for: .opened)...config.translateY(for: .closed) = nextConstant {
        containerView.frame.origin.y += translation.y
      } else {
        containerView.frame.origin.y += translation.y * 0.1
      }

      top.constant = containerView.frame.origin.y

      let halfToOpenProgress = CalcBox.init(top.constant)
        .progress(start: config.translateY(for: .halfOpened), end: config.translateY(for: .opened))
        .clip(min: 0, max: 1)
        .value.fractionCompleted

      let closedToHalfProgress = CalcBox.init(top.constant)
        .progress(start: config.translateY(for: .closed), end: config.translateY(for: .halfOpened))
        .clip(min: 0, max: 1)
        .value.fractionCompleted

      let wholeProgress = CalcBox.init(top.constant)
        .progress(start: config.translateY(for: .closed), end: config.translateY(for: .opened))
        .clip(min: 0, max: 1)
        .value.fractionCompleted

      runningAnimatorsForHalfOpenedToOpened.forEach {
        $0.fractionComplete = halfToOpenProgress
      }

      runningAnimatorsForClosed.forEach {
        $0.fractionComplete = closedToHalfProgress
      }

    case .ended, .cancelled, .failed:

      let target = targetForEndDragging(velocity: gesture.velocity(in: gesture.view!))
      continueInteractiveTransition(target: target, velocity: gesture.velocity(in: gesture.view!))
    default:
      break
    }

    gesture.setTranslation(.zero, in: gesture.view!)
  }

  private func animateTransitionIfNeeded() {

    containerDraggingAnimator?.stopAnimation(true)

    if runningAnimatorsForHalfOpenedToOpened.isEmpty {

      dimming: do {
        let dimmingColor = UIColor(white: 0, alpha: 0.2)

        self.backdropView.backgroundColor = .clear

        let animator = UIViewPropertyAnimator(
          duration: 0.3,
          curve: .easeOut) {

            self.backdropView.backgroundColor = dimmingColor
        }

        dimmingAnimator = animator

        animator.addCompletion { _ in
          self.runningAnimatorsForHalfOpenedToOpened.removeAll { $0 == animator }
        }

        runningAnimatorsForHalfOpenedToOpened.append(animator)

        animator.startAnimation()

      }

    } else {
      runningAnimatorsForHalfOpenedToOpened.forEach {
        $0.isReversed = false
      }
    }

    if runningAnimatorsForClosed.isEmpty {

      hideBody: do {

        self.contentView?.bodyView?.alpha = 0

        let animator = UIViewPropertyAnimator(
          duration: 0.3,
          curve: .easeOut) {

            self.contentView?.bodyView?.alpha = 1
        }

        animator.addCompletion { _ in
          self.runningAnimatorsForClosed.removeAll { $0 == animator }
        }

        runningAnimatorsForClosed.append(animator)

        animator.startAnimation()

      }

    } else {
      runningAnimatorsForClosed.forEach {
        $0.isReversed = false
      }
    }
  }

  private func startInteractiveTransition() {

    runningAnimatorsForHalfOpenedToOpened.forEach {
      $0.pauseAnimation()
    }

    runningAnimatorsForClosed.forEach {
      $0.pauseAnimation()
    }
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    let height = containerView.bounds.height

    config.setTranslateY(
      closed: height - 88,
      opened: 44,
      halfOpened: height - 240
    )

  }

  private func continueInteractiveTransition(target: State, velocity: CGPoint) {

    let targetTranslateY = config.translateY(for: target)
    let currentTranslateY = top.constant

    func makeVelocity() -> CGVector {

      let base = CGVector(
        dx: 0,
        dy: targetTranslateY - currentTranslateY
      )

      var initialVelocity = CGVector(
        dx: 0,
        dy: min(abs(velocity.y / base.dy), 5)
      )

      if initialVelocity.dy.isInfinite || initialVelocity.dy.isNaN {
        initialVelocity.dy = 0
      }

      return initialVelocity
    }

    let animator = UIViewPropertyAnimator.init(
      duration: 0.4,
      timingParameters: UISpringTimingParameters(
        mass: 4.5,
        stiffness: 1300,
        damping: 300, initialVelocity: makeVelocity()
      )
    )

    // flush pending updates
    self.layoutIfNeeded()

    animator
      .addAnimations {
        self.top.constant = targetTranslateY
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    animator.startAnimation()

    containerDraggingAnimator = animator

    if currentState == .opened {

    } else {

    }

    switch target {
    case .closed:
      runningAnimatorsForHalfOpenedToOpened.forEach {
        $0.isReversed = true
      }

      runningAnimatorsForClosed.forEach {
        $0.isReversed = true
      }

    case .halfOpened:
      runningAnimatorsForHalfOpenedToOpened.forEach {
        $0.isReversed = true
      }

      break
    case .opened:
      break
    }

    runningAnimatorsForHalfOpenedToOpened.forEach {
      $0.continueAnimation(withTimingParameters: nil, durationFactor: 1)
    }

    runningAnimatorsForClosed.forEach {
      $0.continueAnimation(withTimingParameters: nil, durationFactor: 1)
    }

    currentState = target

  }

  private func targetForEndDragging(velocity: CGPoint) -> State {

    let ty = containerView.frame.origin.y
    let vy = velocity.y

    switch ty {
    case ...config.translateY(for: .opened):

      return .opened

    case config.translateY(for: .opened)..<config.translateY(for: .halfOpened):

      switch vy {
      case -20...20:
        let bound = (config.translateY(for: .halfOpened) - config.translateY(for: .opened)) / 2
        return bound < ty ? .halfOpened : .opened
      case ...(-20):
        return .opened
      case 20...:
        return .halfOpened
      default:
        assertionFailure()
        return .opened
      }

    case config.translateY(for: .halfOpened)..<config.translateY(for: .closed):

      switch vy {
      case -20...20:
        let bound = (config.translateY(for: .closed) - config.translateY(for: .halfOpened)) / 2
        return bound < ty ? .closed : .halfOpened
      case ...(-20):
        return .halfOpened
      case 20...:
        return .closed
      default:
        assertionFailure()
        return .closed
      }

    case config.translateY(for: .closed)...:

      return .closed

    default:
      assertionFailure()
      return .opened
    }
  }

}
