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

/// The RideauViewDelegate protocol defines methods that allow you to know events and manage animations.
public protocol RideauViewDelegate : class {
  
  /// Asks what should run animations alongside dragging using UIViewPropertyAnimator.
  ///
  /// As a side of implementation, It will be asked when the first time of dragging.
  /// Plus, the returned set of UIViewPropertyAnimator will be retained according to the lifetime of RideauView.
  /// These animators won't be stopped (using pausedOnCompleted).
  ///
  /// - Parameters:
  ///   - rideauView:
  ///   - range:
  /// - Returns:
  @available(iOS 11, *)
  func rideauView(_ rideauView: RideauView, animatorsAlongsideMovingIn range: ResolvedSnapPointRange) -> [UIViewPropertyAnimator]
  
  /// Tells the delegate that current snap-point will move to the other snap-point
  ///
  /// - Parameters:
  ///   - rideauView:
  ///   - snapPoint:
  func rideauView(_ rideauView: RideauView, willMoveTo snapPoint: RideauSnapPoint)
  
  /// Tells the delegate that current snap-point did move to the other snap-point
  ///
  /// - Parameters:
  ///   - rideauView:
  ///   - snapPoint:
  func rideauView(_ rideauView: RideauView, didMoveTo snapPoint: RideauSnapPoint)

}

/// An object that manages content view with some gesture events.
public final class RideauView : RideauTouchThroughView {
  
  // MARK: - Nested types
  
  public enum TrackingScrollViewOption: Equatable {
    case noTracking
    case automatic
    case specific(UIScrollView)
  }
  
  public enum TopMarginOption: Equatable {
    case fromTop(CGFloat)
    case fromSafeArea(CGFloat)
  }
  
  /// An object that describing behavior of RideauView
  public struct Configuration: Equatable {
    
    public var snapPoints: Set<RideauSnapPoint>
    
    public var topMarginOption: TopMarginOption
    
    public init(
      snapPoints: [RideauSnapPoint] = [.hidden, .fraction(1)],
      topMarginOption: TopMarginOption = .fromSafeArea(20)
      ) {
      self.snapPoints = Set(snapPoints)
      self.topMarginOption = topMarginOption
    }
    
  }
  
  // MARK: - Properties
  
  public var trackingScrollViewOption: TrackingScrollViewOption {
    get {
      return backingView.trackingScrollViewOption
    }
    set {
      backingView.trackingScrollViewOption = newValue
    }
  }
  
  public var isTrackingKeyboard: Bool = true {
    didSet {
      if !isTrackingKeyboard {
        self.bottom.constant = 0
      }
      //      updateBottom()
    }
  }
  
  public var backdropView: UIView {
    return backingView.backdropView
  }
  
  public var containerView: RideauContainerView {
    return backingView.containerView
  }
  
  public var configuration: Configuration {
    return backingView.configuration
  }
  
  public weak var delegate: RideauViewDelegate?
  
  // This is for RidauViewController
    
  internal var willChangeSnapPoint: (RideauSnapPoint) -> Void {
    get {
      return backingView.willChangeSnapPoint
    }
    set {
      backingView.willChangeSnapPoint = newValue
    }
  }
  
  internal var didChangeSnapPoint: (RideauSnapPoint) -> Void {
    get {
      return backingView.didChangeSnapPoint
    }
    set {
      backingView.didChangeSnapPoint = newValue
    }
  }
  
  private var bottomFromKeyboard: NSLayoutConstraint!
  
  private var bottom: NSLayoutConstraint!
  
  private let backingView: RideauInternalView

  // MARK: - Initializers
  
  public convenience init(frame: CGRect, configure: (inout Configuration) -> Void) {
    var configuration = Configuration()
    configure(&configuration)
    self.init(frame: frame, configuration: configuration)
  }
  
  public init(frame: CGRect, configuration: Configuration) {
    
    self.backingView = RideauInternalView(
      frame: frame,
      configuration: configuration
    )
    
    super.init(frame: frame)
    
    backgroundColor = .clear
    backingView.delegate = self
    backingView.translatesAutoresizingMaskIntoConstraints = false
    super.addSubview(backingView)
    backingView.setup()
    
    bottom = backingView.bottomAnchor.constraint(equalTo: bottomAnchor)
    
    NSLayoutConstraint.activate([
      backingView.topAnchor.constraint(equalTo: topAnchor),
      backingView.rightAnchor.constraint(equalTo: rightAnchor),
      backingView.leftAnchor.constraint(equalTo: leftAnchor),
      bottom,
      ])
    
    startObserveKeyboard()
  }
  
  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Functions
  
  /// Update configuration
  ///
  /// RideauView updates own layout from current with new configuration
  /// If snappoints has differences, RideauView will change snappoint to initial point.
  /// We can call move() after this method.
  public func update(configuration: RideauView.Configuration) {
    backingView.update(configuration: configuration)
  }
  
  public func register(other panGesture: UIPanGestureRecognizer) {
    backingView.register(other: panGesture)
  }
  
  @available(*, unavailable, message: "Don't add view directory, add to RideauView.containerView")
  public override func addSubview(_ view: UIView) {
    assertionFailure("Don't add view directory, add to RideauView.containerView")
    super.addSubview(view)
  }
  
  public func move(to snapPoint: RideauSnapPoint, animated: Bool, completion: @escaping () -> Void) {
    
    backingView.move(to: snapPoint, animated: animated, completion: completion)
  }
  
  private func startObserveKeyboard() {
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillChangeFrame(_:)),
      name: UIResponder.keyboardWillChangeFrameNotification,
      object: nil
    )
    
  }
  
  @objc
  private dynamic func keyboardWillChangeFrame(_ note: Notification) {
    
    guard isTrackingKeyboard else {
      return
    }
    
    var keyboardHeight: CGFloat? {
      guard let v = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
        return nil
      }
      
      let screenHeight = UIScreen.main.bounds.height
      return screenHeight - v.cgRectValue.minY
    }
    
    var animationDuration: Double {
      if let number = note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
        return number.doubleValue
      } else {
        return 0.25
      }
    }
    
    var animationCurve: Int {
      if let number = note.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber {
        return number.intValue
      }
      return UIView.AnimationCurve.easeInOut.rawValue
    }
    
    UIView.animate(
      withDuration: animationDuration,
      delay: 0,
      options: UIView.AnimationOptions(rawValue: UInt(animationCurve << 16)),
      animations: {
        self.bottom.constant = -keyboardHeight!
        self.layoutIfNeeded()
    },
      completion: nil
    )
    
  }
}

extension RideauView : RideauInternalViewDelegate {
  
  @available(iOS 11, *)
  func rideauView(_ rideauInternalView: RideauInternalView, animatorsAlongsideMovingIn range: ResolvedSnapPointRange) -> [UIViewPropertyAnimator] {
    return delegate?.rideauView(self, animatorsAlongsideMovingIn: range) ?? []
  }
  
  func rideauView(_ rideauInternalView: RideauInternalView, willMoveTo snapPoint: RideauSnapPoint) {
    delegate?.rideauView(self, willMoveTo: snapPoint)
  }
  
  func rideauView(_ rideauInternalView: RideauInternalView, didMoveTo snapPoint: RideauSnapPoint) {
    delegate?.rideauView(self, didMoveTo: snapPoint)
  }
  
}
