//
//  CabinetView.swift
//  Cabinet
//
//  Created by muukii on 9/22/18.
//  Copyright © 2018 muukii. All rights reserved.
//

import UIKit

public protocol CabinetViewDelegate : class {
  
}

public final class CabinetView : TouchThroughView {
  
  public struct Configuration {
    
    public var snapPoints: Set<SnapPoint> = [.fraction(0), .fraction(1)]
    
    #warning("Unimplemented")
    public var initialSnapPoint: SnapPoint = .fraction(0)
    
    public init() {
      
    }
  }
  
  private let backingView: CabinetInternalView

  internal var didChangeSnapPoint: (SnapPoint) -> Void {
    get {
      return backingView.didChangeSnapPoint
    }
    set {
      backingView.didChangeSnapPoint = newValue
    }
  }
  
  public var containerView: CabinetContainerView {
    return backingView.containerView
  }
  
  private let keyboardLayoutGuide = KeyboardLayoutGuide()
  
  // MARK: - Initializers
  
  public convenience init(frame: CGRect, configure: (inout Configuration) -> Void) {
    var configuration = Configuration()
    configure(&configuration)
    self.init(frame: frame, configuration: configuration)
  }
  
  public init(frame: CGRect, configuration: Configuration?) {
    self.backingView = CabinetInternalView(frame: frame, configuration: configuration)
    super.init(frame: frame)
    
    addLayoutGuide(keyboardLayoutGuide)
    keyboardLayoutGuide.setUp()
    
    backingView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(backingView)
    
    let keyboardTop = keyboardLayoutGuide.topAnchor
    
    NSLayoutConstraint.activate([
      backingView.topAnchor.constraint(equalTo: topAnchor),
      backingView.rightAnchor.constraint(equalTo: rightAnchor),
      backingView.bottomAnchor.constraint(equalTo: keyboardTop),
      backingView.leftAnchor.constraint(equalTo: leftAnchor),
      ])
  }
  
  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func set(snapPoint: SnapPoint, animated: Bool, completion: @escaping () -> Void) {
    
    backingView.set(snapPoint: snapPoint, animated: animated, completion: completion)
  }
}

final class CabinetInternalView : TouchThroughView {
  
  // Needs for internal usage
  internal var didChangeSnapPoint: (SnapPoint) -> Void = { _ in }
  
  private var top: NSLayoutConstraint!

  private let backdropView = TouchThroughView()

  public let containerView = CabinetContainerView()
  
  public let configuration: CabinetView.Configuration
  
  private var internalConfiguration: InternalConfiguration = .init()

  private var containerDraggingAnimator: UIViewPropertyAnimator?

  private var dimmingAnimator: UIViewPropertyAnimator?
  
  private var animatorStore: AnimatorStore = .init()
  
  private var sizeThatLastUpdated: CGSize?
  
  init(frame: CGRect, configuration: CabinetView.Configuration?) {
    self.configuration = configuration ?? .init()
    super.init(frame: .zero)
    setup()
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  func set(snapPoint: SnapPoint, animated: Bool, completion: @escaping () -> Void) {
    
    preventCurrentAnimations: do {
      
      animatorStore.allAnimators().forEach {
        $0.stopAnimation(true)
      }
      
      animatorStore.removeAllAnimations()
      
      containerDraggingAnimator?.stopAnimation(true)
    }

    animateTransitionIfNeeded()
    
    guard let target = internalConfiguration.snapPoints.first(where: { $0.source == snapPoint }) else {
      assertionFailure("Not found such as snappoint")
      return
    }
    
    if animated {
      continueInteractiveTransition(target: target, velocity: .zero, completion: completion)
    } else {
      UIView.performWithoutAnimation {
        continueInteractiveTransition(target: target, velocity: .zero, completion: completion)
      }
    }
    
  }
  
  private func setup() {
    
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(backdropView)
    backdropView.frame = bounds
    backdropView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    addSubview(containerView)
    containerView.set(owner: self)
    
    top = containerView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
    
    NSLayoutConstraint.activate([
      top,
      containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
      containerView.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: 0),
      containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
      ])
    
    gesture: do {

      let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
      containerView.addGestureRecognizer(pan)
    }

  }

  @objc private func handlePan(gesture: UIPanGestureRecognizer) {
    
    let translation = gesture.translation(in: self)
    let nextCurrent = round((containerView.layer.presentation() ?? containerView.layer).frame.origin.y + translation.y)
    let location = internalConfiguration.currentLocation(from: nextCurrent)
    
    switch gesture.state {
    case .began:
      animateTransitionIfNeeded()
      startInteractiveTransition()
      fallthrough
    case .changed:
      
      switch location {
      case .exact:
        containerView.layer.frame.origin.y = nextCurrent
      case .between(let range):
        
        let fractionCompleteInRange = CalcBox.init(top.constant)
          .progress(
            start: range.start.pointsFromSafeAreaTop,
            end: range.end.pointsFromSafeAreaTop
          )
          .clip(min: 0, max: 1)
          .value
          .fractionCompleted
        
        containerView.layer.frame.origin.y = nextCurrent
        
        animatorStore[range]?.forEach {
          $0.isReversed = false
          $0.pauseAnimation()
          $0.fractionComplete = fractionCompleteInRange
        }
        
        animatorStore.animators(after: range).forEach {
          $0.isReversed = false
          $0.pauseAnimation()
          $0.fractionComplete = 0
        }
        
        animatorStore.animators(before: range).forEach {
          $0.isReversed = false
          $0.pauseAnimation()
          $0.fractionComplete = 1
        }
        
      case .outOf(let point):
        containerView.layer.frame.origin.y += translation.y * 0.1
      }
      
    case .ended, .cancelled, .failed:

      let target = targetForEndDragging(velocity: gesture.velocity(in: gesture.view!))
      continueInteractiveTransition(target: target, velocity: gesture.velocity(in: gesture.view!), completion: {})
    default:
      break
    }

    gesture.setTranslation(.zero, in: gesture.view!)

  }

  private func animateTransitionIfNeeded() {

    
  }

  private func startInteractiveTransition() {
    
    containerDraggingAnimator?.pauseAnimation()
    containerDraggingAnimator?.stopAnimation(true)
    
    animatorStore.allAnimators().forEach {
      $0.pauseAnimation()
    }
    
  }

  override func layoutSubviews() {
    
    func _setup() {
      
      let offset: CGFloat
      
      if #available(iOSApplicationExtension 11.0, *) {
        offset = safeAreaInsets.top
      } else {
        offset = 20 // Temp
      }
      
      let points = configuration.snapPoints.map { snapPoint -> ResolvedSnapPoint in
        switch snapPoint {
        case .fraction(let fraction):
          let height = self.bounds.height - offset
          let value = round(height - height * fraction) + offset
          return .init(value, source: snapPoint)
        case .pointsFromSafeAreaTop(let points):
          return .init(points + offset, source: snapPoint)
        }
      }
      
      internalConfiguration.set(snapPoints: points)
    }
    
    if sizeThatLastUpdated == nil {
      super.layoutSubviews()
      sizeThatLastUpdated = bounds.size
      _setup()
      
      if let initial = internalConfiguration.snapPoints.last {
        set(snapPoint: initial.source, animated: false, completion: {})
      }
      
      return
    }
    
    let current = internalConfiguration.currentLocation(from: containerView.frame.origin.y)
    
    super.layoutSubviews()
    
    guard sizeThatLastUpdated != bounds.size else {
      return
    }
    
    sizeThatLastUpdated = bounds.size
    
    _setup()
    
    switch current {
    case .between(let range):
      set(snapPoint: range.end.source, animated: false, completion: {})
    case .exact(let point):
      set(snapPoint: point.source, animated: false, completion: {})
    case .outOf(let point):
      set(snapPoint: point.source, animated: false, completion: {})
    }
    
  }

  private func continueInteractiveTransition(target: ResolvedSnapPoint, velocity: CGPoint, completion: @escaping () -> Void) {
    
    let targetTranslateY = target.pointsFromSafeAreaTop
    let currentTranslateY = (containerView.layer.presentation() ?? containerView.layer).frame.origin.y

    func makeVelocity() -> CGVector {

      let base = CGVector(
        dx: 0,
        dy: targetTranslateY - currentTranslateY
      )

      var initialVelocity = CGVector(
        dx: 0,
        dy: min(abs(velocity.y / base.dy), 15)
      )

      if initialVelocity.dy.isInfinite || initialVelocity.dy.isNaN {
        initialVelocity.dy = 0
      }

      return initialVelocity
    }

    let animator = UIViewPropertyAnimator.init(
      duration: 0.4,
      timingParameters: UISpringTimingParameters(
        mass: 5,
        stiffness: 1300,
        damping: 300, initialVelocity: makeVelocity()
      )
    )
    
    // flush pending updates
    
    self.layoutIfNeeded()
    self.top.constant = targetTranslateY
    
    animator
      .addAnimations {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
//        self.containerView.frame.origin.y = targetTranslateY
    }
    
    animator.addCompletion { _ in
      completion()
      self.didChangeSnapPoint(target.source)
    }
    
    animator.isInterruptible = true
    
    animator.startAnimation()

    containerDraggingAnimator = animator

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
        return range.start
      case 20...:
        return range.end
      default:
        fatalError()
      }
      
    case .exact(let point):
      return point
      
    case .outOf(let point):
      return point
    }
   
  }

}

extension CabinetInternalView {
  
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
    
    func animators(after: ResolvedSnapPointRange) -> [UIViewPropertyAnimator] {
      
      return backingStore
        .filter { $0.key.end < after.start }
        .reduce(into: [UIViewPropertyAnimator]()) { (result, args) in
          result += args.value
      }
      
    }
    
    func animators(before: ResolvedSnapPointRange) -> [UIViewPropertyAnimator] {
      
      return backingStore
        .filter { $0.key.start >= before.start }
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
  
  private struct InternalConfiguration {
    
    private(set) var snapPoints: [ResolvedSnapPoint] = []
    
    mutating func set<T : Collection>(snapPoints: T) where T.Element == ResolvedSnapPoint {
      self.snapPoints = snapPoints.sorted(by: <)
    }
    
    enum Location {
      case between(ResolvedSnapPointRange)
      case exact(ResolvedSnapPoint)
      case outOf(ResolvedSnapPoint)
    }
    
    func currentLocation(from currentPoint: CGFloat) -> Location {
      
      if let point = snapPoints.first(where: { $0.pointsFromSafeAreaTop == currentPoint }) {
        return .exact(point)
      }
      
      precondition(!snapPoints.isEmpty)
      
      let firstHalf = snapPoints.lazy.filter { $0.pointsFromSafeAreaTop <= currentPoint }
      let secondHalf = snapPoints.lazy.filter { $0.pointsFromSafeAreaTop >= currentPoint }
      
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
}
