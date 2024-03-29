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

#if canImport(UIKit)
import UIKit

/// The RideauViewDelegate protocol defines methods that allow you to know events and manage animations.
public protocol RideauViewDelegate: AnyObject {

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

  /// Tells the snap point will change to another snap point.
  ///
  /// - Warning: RideauInternalView will not always move to the destination snap point. If the user interrupted moving animation, didChangeSnapPoint brings another snap point up to you.
  func rideauView(_ rideauView: RideauView, willMoveTo snapPoint: RideauSnapPoint)

  /// Tells the new snap point that currently RidauView snaps.
  func rideauView(_ rideauView: RideauView, didMoveTo snapPoint: RideauSnapPoint)

}

extension RideauView {
  /// An object that describing behavior of RideauView
  public struct Configuration: Equatable {

    public struct ScrollViewOption: Equatable {
      /// an enum that represents how RideauView resolves multiple scrolling occasions. (RideauView's swipe down and scroll view inside content.)
      public enum ScrollViewDetection: Equatable {
        case noTracking
        case automatic
        case specific(UIScrollView)
      }
      /**
       A Boolean value that indicates whether UIScrollView can bouncing by scrolling when started from scrolling down.

       If `false`, any continuous scrolling affects sheet moving.
       It recommends setting as true when presenting the sheet as modally since the user might dismiss it unexpectedly.
       */
      public var allowsBouncing: Bool
      public var scrollViewDetection: ScrollViewDetection

    }

    public enum TopMarginOption: Equatable {
      case fromTop(CGFloat)
      case fromSafeArea(CGFloat)
    }

    public var snapPoints: Set<RideauSnapPoint>

    public var topMarginOption: TopMarginOption

    public var scrollViewOption: ScrollViewOption = .init(allowsBouncing: false, scrollViewDetection: .automatic)

    public init(
      modify: (inout Self) -> Void
    ) {
      var base = Configuration()
      modify(&base)
      self = base
    }

    public init(
      snapPoints: [RideauSnapPoint] = [.hidden, .fraction(1)],
      topMarginOption: TopMarginOption = .fromSafeArea(20)
    ) {
      self.snapPoints = Set(snapPoints)
      self.topMarginOption = topMarginOption
    }

  }
}

/**
 A view that manages sheet UI.

 You may use ``RideauContentType`` in a view what you want to show in the sheet. 
 */
public final class RideauView: RideauTouchThroughView {

  public struct Handlers {

    public var animatorsAlongsideMoving: ((ResolvedSnapPointRange) -> [UIViewPropertyAnimator])?

    public var willMoveTo: ((RideauSnapPoint) -> Void)?

    public var didMoveTo: ((RideauSnapPoint) -> Void)?

    public init() {

    }
  }

  // MARK: - Properties

  public var configuration: Configuration {
    return hostingView.configuration
  }

  @available(*, deprecated, message: "This property has been moved into RideauView.Configuration.")
  public var trackingScrollViewOption: RideauView.Configuration.ScrollViewOption.ScrollViewDetection {
    get {
      return configuration.scrollViewOption.scrollViewDetection
    }
    set {
      var currentConfiguration = configuration
      currentConfiguration.scrollViewOption.scrollViewDetection = newValue
      hostingView.update(configuration: currentConfiguration)
    }
  }

  public var isTrackingKeyboard: Bool = true {
    didSet {
      if !isTrackingKeyboard {
        self.bottom.constant = 0
      }
    }
  }

  public var backdropView: UIView {
    return hostingView.backdropView
  }

  public var containerView: RideauContentContainerView {
    return hostingView.containerView
  }

  public var handlers: Handlers {
    get {
      hostingView.handlers
    }
    set {
      hostingView.handlers = newValue
    }
  }

  public weak var delegate: RideauViewDelegate? {
    get {
      hostingView.delegate
    }
    set {
      hostingView.delegate = newValue
    }
  }

  /// A set of handlers for inter-view communication.
  internal var internalHandlers: RideauHostingView.InternalHandlers {
    get { hostingView.internalHandlers }
    set { hostingView.internalHandlers = newValue }
  }

  private var bottomFromKeyboard: NSLayoutConstraint!

  private var bottom: NSLayoutConstraint!

  private let hostingView: RideauHostingView

  // MARK: - Initializers

  @available(*, deprecated, message: "Use init(frame, configuration). now supports RideauView.Configuration.init(modify:)")
  public convenience init(
    frame: CGRect,
    configure: (inout Configuration) -> Void
  ) {
    var configuration = Configuration()
    configure(&configuration)
    self.init(frame: frame, configuration: configuration)
  }

  public init(
    frame: CGRect = .zero,
    configuration: Configuration
  ) {

    self.hostingView = RideauHostingView(
      frame: frame,
      configuration: configuration
    )

    super.init(frame: frame)

    backgroundColor = .clear
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    super.addSubview(hostingView)
    hostingView.setup()

    bottom = hostingView.bottomAnchor.constraint(equalTo: bottomAnchor)

    NSLayoutConstraint.activate([
      hostingView.topAnchor.constraint(equalTo: topAnchor),
      hostingView.rightAnchor.constraint(equalTo: rightAnchor),
      hostingView.leftAnchor.constraint(equalTo: leftAnchor),
      bottom,
    ])

    startObserveKeyboard()
  }

  @available(*, unavailable)
  public required init?(
    coder aDecoder: NSCoder
  ) {
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
    hostingView.update(configuration: configuration)
  }

  public func register(other panGesture: UIPanGestureRecognizer) {
    hostingView.register(other: panGesture)
  }

  @available(*, unavailable, message: "Don't add view directory, add to RideauView.containerView")
  public override func addSubview(_ view: UIView) {
    assertionFailure("Don't add view directory, add to RideauView.containerView")
    super.addSubview(view)
  }

  public func move(
    to snapPoint: RideauSnapPoint,
    animated: Bool,
    completion: @escaping () -> Void
  ) {

    hostingView.move(
      to: snapPoint,
      animated: animated,
      completion: completion
    )
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

#endif
