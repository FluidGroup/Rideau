//
//  CabinetView.swift
//  Cabinet
//
//  Created by muukii on 9/22/18.
//  Copyright © 2018 muukii. All rights reserved.
//

import UIKit

public final class CabinetView : UIView {

  public enum State {
    case closed
    case opened
    case halfOpened
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

  private let containerView = UIView()

  private var config: Config = .init()

  private var finishingAnimators: [UIViewPropertyAnimator] = []

  public override init(frame: CGRect) {
    super.init(frame: .zero)
    setup()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  private func setup() {

    containerView.translatesAutoresizingMaskIntoConstraints = false

    addSubview(containerView)

    #if DEBUG
    containerView.backgroundColor = UIColor.init(white: 0.6, alpha: 1)
    #endif

    top = containerView.topAnchor.constraint(equalTo: topAnchor, constant: 64)

    NSLayoutConstraint.activate([
      top,
      containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
      containerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1, constant: -44),
//      containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
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
      startInteractiveTransition()
    case .changed:

      let translation = gesture.translation(in: gesture.view!)

      containerView.frame.origin.y += translation.y

//      containerView.transform = nextTransform

    case .ended, .cancelled, .failed:

      let target = targetForEndDragging(velocity: gesture.velocity(in: gesture.view!))
      endInteractiveTransition(target: target, velocity: gesture.velocity(in: gesture.view!))
    default:
      break
    }

    gesture.setTranslation(.zero, in: gesture.view!)
  }

  private func startInteractiveTransition() {
    finishingAnimators.forEach {
      $0.stopAnimation(true)
    }
    finishingAnimators = []
  }

  private func updateInteracrtiveTransition(y: CGFloat) {

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

  private func endInteractiveTransition(target: State, velocity: CGPoint) {

    let targetTranslateY = config.translateY(for: target)
    let currentTranslateY = top.constant

    let base = CGVector(
      dx: 0,
      dy: targetTranslateY - currentTranslateY
    )

    var initialVelocity = CGVector(
      dx: 0,
      dy: abs(velocity.y / base.dy)
    )

    if initialVelocity.dy.isInfinite || initialVelocity.dy.isNaN {
      initialVelocity.dy = 0
    }

    print(targetTranslateY, initialVelocity)

    let animator = UIViewPropertyAnimator.init(
      duration: 0.4,
      timingParameters: UISpringTimingParameters(
        mass: 4.5,
        stiffness: 1300,
        damping: 300, initialVelocity: initialVelocity
      )
    )

    self.layoutIfNeeded()


    animator
      .addAnimations {
        self.top.constant = targetTranslateY
        self.layoutIfNeeded()
    }

    finishingAnimators.append(animator)

    animator.startAnimation()

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
