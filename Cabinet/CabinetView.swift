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

  private var heightConstraint: NSLayoutConstraint!

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

    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: topAnchor, constant: 64),
      containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
      containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
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

      let nextTransform = containerView.transform.translatedBy(x: 0, y: translation.y)

      containerView.transform = nextTransform

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
      opened: 0,
      halfOpened: height - 240
    )

  }

  private func endInteractiveTransition(target: State, velocity: CGPoint) {

    let targetTranslateY = config.translateY(for: target)
    let currentTranslateY = containerView.transform.ty

    let base = CGVector(
      dx: 0,
      dy: abs(targetTranslateY - currentTranslateY)
    )

    var initialVelocity = CGVector(
      dx: 0,
      dy: (velocity.y / base.dy) * 100
    )

    initialVelocity.dy = initialVelocity.dy.isNaN ? 0 : initialVelocity.dy

    print(initialVelocity)

    let animator = UIViewPropertyAnimator.init(
      duration: 0.4,
      timingParameters: UISpringTimingParameters(
        mass: 4.5,
        stiffness: 2300,
        damping: 300, initialVelocity: initialVelocity
      )
    )

    animator
      .addAnimations {
        self.containerView.transform = .init(translationX: 0, y: targetTranslateY)
    }

    finishingAnimators.append(animator)

    animator.startAnimation()

  }

  private func targetForEndDragging(velocity: CGPoint) -> State {

    let ty = containerView.transform.ty
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
