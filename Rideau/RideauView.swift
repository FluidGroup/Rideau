//
// Rideau
//
// Copyright (c) 2019 muukii
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

public protocol RideauViewDelegate : class {
  
}

public final class RideauView : TouchThroughView {
  
  public struct Configuration {
    
    public var snapPoints: Set<RideauSnapPoint> = [.hidden, .fraction(1)]
    
    public init() {
      
    }
  }
  
  private let backingView: RideauInternalView

  internal var didChangeSnapPoint: (RideauSnapPoint) -> Void {
    get {
      return backingView.didChangeSnapPoint
    }
    set {
      backingView.didChangeSnapPoint = newValue
    }
  }
  
  public var isTrackingKeyboard: Bool = true {
    didSet {
      if isTrackingKeyboard {
        
      } else {
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
    
  private var bottomFromKeyboard: NSLayoutConstraint!
  private var bottom: NSLayoutConstraint!
  
  // MARK: - Initializers
  
  public convenience init(frame: CGRect, configure: (inout Configuration) -> Void) {
    var configuration = Configuration()
    configure(&configuration)
    self.init(frame: frame, configuration: configuration)
  }
  
  public init(frame: CGRect, configuration: Configuration?) {
    
    self.backingView = RideauInternalView(
      frame: frame,
      configuration: configuration
    )
    
    super.init(frame: frame)
    
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
  
  @available(*, unavailable, message: "Don't add view directory, add to RideauView.containerView")
  public override func addSubview(_ view: UIView) {
    assertionFailure("Don't add view directory, add to RideauView.containerView")
    super.addSubview(view)
  }
  
  public func set(snapPoint: RideauSnapPoint, animated: Bool, completion: @escaping () -> Void) {
    
    backingView.set(snapPoint: snapPoint, animated: animated, completion: completion)
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
  private func keyboardWillChangeFrame(_ note: Notification) {
    
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
    
    if #available(iOS 11, *) {
      self.bottom.constant = -keyboardHeight!
      self.layoutIfNeeded()
    } else {
      // Workaround
      // Changing constant should be done after keyboard animation finished.
      // Otherwise, keyboard will not be appear
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.bottom.constant = -keyboardHeight!
        self.layoutIfNeeded()
      }
    }
  }
}
