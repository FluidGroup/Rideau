//
//  RideauView.swift
//  Rideau
//
//  Created by muukii on 9/22/18.
//  Copyright © 2018 muukii. All rights reserved.
//

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
    addSubview(backingView)
    backingView.setup()
    
    self.bottom = backingView.bottomAnchor.constraint(equalTo: bottomAnchor)
    
    NSLayoutConstraint.activate([
      backingView.topAnchor.constraint(equalTo: topAnchor),
      backingView.rightAnchor.constraint(equalTo: rightAnchor),
      backingView.leftAnchor.constraint(equalTo: leftAnchor),
      self.bottom,
      ])
    
    startObserveKeyboard()
  }
  
  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func set(snapPoint: RideauSnapPoint, animated: Bool, completion: @escaping () -> Void) {
    
    backingView.set(snapPoint: snapPoint, animated: animated, completion: completion)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
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
      }
      else {
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
