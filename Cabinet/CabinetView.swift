//
//  CabinetView.swift
//  Cabinet
//
//  Created by muukii on 9/22/18.
//  Copyright © 2018 muukii. All rights reserved.
//

import UIKit

public protocol CabinetContentViewType : class {

  var scrollViews: [UIScrollView] { get }
}

public final class CabinetView : TouchThroughView {
  
  private struct AnimatorStore {
    
    private var backingStore: [ResolvedSnapPointRange : [UIViewPropertyAnimator]] = [:]
    
    subscript (_ range: ResolvedSnapPointRange) -> [UIViewPropertyAnimator]? {
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
  
  public struct Configuration {
    
    public var snapPoints: Set<SnapPoint> = [.fraction(0), .fraction(1)]
    
    public init() {
      
    }
  }
  
  private struct InternalConfiguration {
    
    var snapPoints: Set<ResolvedSnapPoint> = []
    
    enum Location {
      case between(ResolvedSnapPointRange)
      case outOf(ResolvedSnapPoint)
    }
    
    func currentLocation(from currentPoint: CGFloat) -> Location {
      
      precondition(!snapPoints.isEmpty)
      
      let buffer = snapPoints.sorted(by: <)
      
      let firstHalf = buffer.filter { $0.pointsFromSafeAreaTop <= currentPoint }
      let secondHalf = buffer.filter { $0.pointsFromSafeAreaTop >= currentPoint }
      
      if !firstHalf.isEmpty && !secondHalf.isEmpty {
        
        return .between(ResolvedSnapPointRange(firstHalf.last!, b:  secondHalf.first!))
      }
      
      if firstHalf.isEmpty {
        return .outOf(secondHalf.first!)
      }
      
      if secondHalf.isEmpty {
        return .outOf(firstHalf.last!)
      }
      
      fatalError()
      
    }
  }

  private var top: NSLayoutConstraint!

  private let backdropView = TouchThroughView()

  private let containerView = UIView()

  private weak var contentView: (UIView & CabinetContentViewType)?
  
  public var configuration: Configuration = .init()
  
  private var internalConfiguration: InternalConfiguration = .init()

  private var containerDraggingAnimator: UIViewPropertyAnimator?

  private var dimmingAnimator: UIViewPropertyAnimator?
  
  private var animatorStore: AnimatorStore = .init()
  
  
  public override init(frame: CGRect) {
    super.init(frame: .zero)
    setup()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  public func set(snapPoint: SnapPoint) {
    
    animatorStore.allAnimators().forEach {
      $0.stopAnimation(true)
    }
    
    animatorStore.removeAllAnimations()

    animateTransitionIfNeeded()
    
    guard let target = internalConfiguration.snapPoints.first(where: { $0.source == snapPoint }) else {
      assertionFailure("Not found such as snappoint")
      return
    }
    
    continueInteractiveTransition(target: target, velocity: .zero)
  }

  public func set(contentView: UIView & CabinetContentViewType) {

    containerView.addSubview(contentView)
    contentView.frame = containerView.bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.contentView = contentView
  }

  private func setup() {
    
    let topMargin = UILayoutGuide()
    

    containerView.translatesAutoresizingMaskIntoConstraints = false

    addLayoutGuide(topMargin)
    addSubview(backdropView)
    backdropView.frame = bounds
    backdropView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    addSubview(containerView)
    
    #warning("TODO: For now")
    topMargin.heightAnchor.constraint(equalToConstant: 64).isActive = true
    topMargin.constraintsAffectingLayout(for: .vertical)
    topMargin.topAnchor.constraint(equalTo: topAnchor).isActive = true
    
    top = containerView.topAnchor.constraint(equalTo: topMargin.bottomAnchor, constant: 0)

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

      let current = top.constant + translation.y
      
      let location = internalConfiguration.currentLocation(from: current)
      
      switch location {
      case .between(let range):
        containerView.frame.origin.y += translation.y
        
        let fractionCompleteInRange = CalcBox.init(top.constant)
          .progress(
            start: range.start.pointsFromSafeAreaTop,
            end: range.end.pointsFromSafeAreaTop
          )
          .clip(min: 0, max: 1)
          .value
          .fractionCompleted
        
        let animators = animatorStore[range]
        
        animators?.forEach {
          $0.fractionComplete = fractionCompleteInRange
        }
        
        // TODO: Other fractionComplete of animators should be set as 0 or 1.
        
      case .outOf(let snapPoint):
        containerView.frame.origin.y += translation.y * 0.1
      }

      top.constant = current

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

//    if runningAnimatorsForHalfOpenedToOpened.isEmpty {
//
//      dimming: do {
//        let dimmingColor = UIColor(white: 0, alpha: 0.2)
//
//        self.backdropView.backgroundColor = .clear
//
//        let animator = UIViewPropertyAnimator(
//          duration: 0.3,
//          curve: .easeOut) {
//
//            self.backdropView.backgroundColor = dimmingColor
//        }
//
//        dimmingAnimator = animator
//
//        animator.addCompletion { _ in
//          self.runningAnimatorsForHalfOpenedToOpened.removeAll { $0 == animator }
//        }
//
//        runningAnimatorsForHalfOpenedToOpened.append(animator)
//
//        animator.startAnimation()
//
//      }
//
//    } else {
//      runningAnimatorsForHalfOpenedToOpened.forEach {
//        $0.isReversed = false
//      }
//    }

//    if runningAnimatorsForClosed.isEmpty {
//
//      hideBody: do {
//
//        self.contentView?.bodyView?.alpha = 0
//
//        let animator = UIViewPropertyAnimator(
//          duration: 0.3,
//          curve: .easeOut) {
//
//            self.contentView?.bodyView?.alpha = 1
//        }
//
//        animator.addCompletion { _ in
//          self.runningAnimatorsForClosed.removeAll { $0 == animator }
//        }
//
//        runningAnimatorsForClosed.append(animator)
//
//        animator.startAnimation()
//
//      }
//
//    } else {
//      runningAnimatorsForClosed.forEach {
//        $0.isReversed = false
//      }
//    }
    
  }

  private func startInteractiveTransition() {
    
    animatorStore.allAnimators().forEach {
      $0.pauseAnimation()
    }
    
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    
    let height = containerView.bounds.height
    
    let points = configuration.snapPoints.map { snapPoint -> ResolvedSnapPoint in
      switch snapPoint {
      case .fraction(let fraction):
        return .init(height - height * fraction, source: snapPoint)
      case .pointsFromSafeAreaTop(let points):
        return .init(points, source: snapPoint)
      }
    }
    
    internalConfiguration.snapPoints = .init(points)
    
  }

  private func continueInteractiveTransition(target: ResolvedSnapPoint, velocity: CGPoint) {
    
    let targetTranslateY = target.pointsFromSafeAreaTop
    let currentTranslateY = top.constant

    func makeVelocity() -> CGVector {

      let base = CGVector(
        dx: 0,
        dy: targetTranslateY - currentTranslateY
      )

      var initialVelocity = CGVector(
        dx: 0,
        dy: min(abs(velocity.y / base.dy), 100)
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

//    switch target {
//    case .closed:
//      runningAnimatorsForHalfOpenedToOpened.forEach {
//        $0.isReversed = true
//      }
//
//      runningAnimatorsForClosed.forEach {
//        $0.isReversed = true
//      }
//
//    case .halfOpened:
//      runningAnimatorsForHalfOpenedToOpened.forEach {
//        $0.isReversed = true
//      }
//
//      break
//    case .opened:
//      break
//    }

//    runningAnimatorsForHalfOpenedToOpened.forEach {
//      $0.continueAnimation(withTimingParameters: nil, durationFactor: 1)
//    }
//
//    runningAnimatorsForClosed.forEach {
//      $0.continueAnimation(withTimingParameters: nil, durationFactor: 1)
//    }

  }

  private func targetForEndDragging(velocity: CGPoint) -> ResolvedSnapPoint {
    
    let ty = containerView.frame.origin.y
    let vy = velocity.y

    let location = internalConfiguration.currentLocation(from: ty)
    
    switch location {
    case .between(let range):
      
      guard let pointCloser = range.pointCloser(by: ty) else {
        fatalError()
      }
      
      switch vy {
      case -20...20:
        return pointCloser
      case ...(-20):
        return range.end
      case 20...:
        return range.start
      default:
        fatalError()
      }
      
    case .outOf(let point):
      return point
    }
   
  }

}
