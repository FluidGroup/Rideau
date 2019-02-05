//
//  CabinetView.swift
//  Cabinet
//
//  Created by muukii on 9/22/18.
//  Copyright © 2018 muukii. All rights reserved.
//

import UIKit

public final class CabinetView : TouchThroughView {
  
  public final class ContainerView : UIView {
    
    public let accessibleAreaLayoutGuide: UILayoutGuide = .init()
    
    private var top: NSLayoutConstraint?
    private var right: NSLayoutConstraint?
    private var left: NSLayoutConstraint?
    private var bottom: NSLayoutConstraint?
    
    unowned let owner: CabinetView
    
    init(owner: CabinetView) {
      
      self.owner = owner
      
      super.init(frame: .zero)
      addLayoutGuide(accessibleAreaLayoutGuide)
      
    }
    
    public override func didMoveToSuperview() {
      super.didMoveToSuperview()
      
      guard let superview = self.superview, superview === owner else {
        assertionFailure()
        return
      }
      
      NSLayoutConstraint.deactivate([
        top, right, left, bottom
        ]
        .compactMap { $0 }
      )
      
      self.top = accessibleAreaLayoutGuide.topAnchor.constraint(equalTo: topAnchor)
      self.right = accessibleAreaLayoutGuide.rightAnchor.constraint(equalTo: rightAnchor)
      self.left = accessibleAreaLayoutGuide.leftAnchor.constraint(equalTo: leftAnchor)
      self.bottom = accessibleAreaLayoutGuide.bottomAnchor.constraint(equalTo: owner.bottomAnchor)
      
      NSLayoutConstraint.activate([
        top, right, left, bottom
        ]
        .compactMap { $0 }
      )
      
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    internal func updateLayoutGuide(with cabinetView: CabinetView) {
      
    }
    
  }
  
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

  private var top: NSLayoutConstraint!

  private let backdropView = TouchThroughView()

  public lazy var containerView = ContainerView(owner: self)
  
  public var configuration: Configuration = .init()
  
  private var internalConfiguration: InternalConfiguration = .init()

  private var containerDraggingAnimator: UIViewPropertyAnimator?

  private var dimmingAnimator: UIViewPropertyAnimator?
  
  private var animatorStore: AnimatorStore = .init()
  
  private var sizeThatLastUpdated: CGSize?
  
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

  private func setup() {
    
    containerView.translatesAutoresizingMaskIntoConstraints = false
  
    addSubview(backdropView)
    backdropView.frame = bounds
    backdropView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    addSubview(containerView)
    
    top = containerView.topAnchor.constraint(equalTo: topAnchor, constant: 0)

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

      let nextCurrent = containerView.frame.origin.y + translation.y
      
      let location = internalConfiguration.currentLocation(from: nextCurrent)
      
      switch location {
      case .exact:
        containerView.frame.origin.y = nextCurrent
      case .between(let range):
        
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
        
        containerView.frame.origin.y = nextCurrent
        
      case .outOf(let snapPoint):
        containerView.frame.origin.y += translation.y * 0.1
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
    
  }

  private func startInteractiveTransition() {
    
    animatorStore.allAnimators().forEach {
      $0.pauseAnimation()
    }
    
  }

  public override func layoutSubviews() {
    
    func _setup() {
      
      let offset: CGFloat
      
      if #available(iOSApplicationExtension 11.0, *) {
        offset = safeAreaInsets.top
      } else {
        offset = 20 // Temp
      }
      
      let height = containerView.bounds.height + offset
      
      let points = configuration.snapPoints.map { snapPoint -> ResolvedSnapPoint in
        switch snapPoint {
        case .fraction(let fraction):
          return .init(round(height - height * fraction), source: snapPoint)
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
      
      if let initial = internalConfiguration.snapPoints.first {
        set(snapPoint: initial.source)
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
      set(snapPoint: range.end.source)
    case .exact(let point):
      set(snapPoint: point.source)
    case .outOf(let point):
      set(snapPoint: point.source)
    }
    
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

    animator
      .addAnimations {
        self.top.constant = targetTranslateY
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

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
