//
//  Keyboard+LayoutGuide.swift
//  KeyboardLayoutGuide
//
//  Created by Sacha DSO on 14/11/2017.
//  Copyright © 2017 freshos. All rights reserved.
//
import UIKit

private class Keyboard {
  static let shared = Keyboard()
  var currentHeight: CGFloat = 0
}

class KeyboardLayoutGuide: UILayoutGuide {
  
  private var heightConstraint: NSLayoutConstraint!
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init() {
    super.init()
    
    // Observe keyboardWillChangeFrame notifications
    let nc = NotificationCenter.default
    nc.addObserver(
      self,
      selector: #selector(keyboardWillChangeFrame(_:)),
      name: UIResponder.keyboardWillChangeFrameNotification,
      object: nil
    )
    
  }
  
  internal func setUp() {
    guard let view = owningView else {
      return
    }
    
    let height = heightAnchor.constraint(equalToConstant: Keyboard.shared.currentHeight)
    self.heightConstraint = height
    NSLayoutConstraint.activate([
      height,
      leftAnchor.constraint(equalTo: view.leftAnchor),
      rightAnchor.constraint(equalTo: view.rightAnchor),
      ])
    let viewBottomAnchor = view.bottomAnchor
    bottomAnchor.constraint(equalTo: viewBottomAnchor).isActive = true
  }
  
  @objc
  private func keyboardWillChangeFrame(_ note: Notification) {
        
    if let height = note.keyboardHeight {
      heightConstraint.constant = height
      animate(note)
      Keyboard.shared.currentHeight = height
    }
  }
  
  private func animate(_ note: Notification) {
    
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
    
//    owningView?.layoutIfNeeded()
    
    UIView.animate(
      withDuration: animationDuration,
      delay: 0,
      options: UIView.AnimationOptions(rawValue: UInt(animationCurve << 16)),
      animations: {
        self.owningView?.layoutIfNeeded()
    },
      completion: nil
    )
    
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

extension Notification {
  var keyboardHeight: CGFloat? {
    guard let v = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
      return nil
    }
    // Weirdly enough UIKeyboardFrameEndUserInfoKey doesn't have the same behaviour
    // in ios 10 or iOS 11 so we can't rely on v.cgRectValue.width
    let screenHeight = UIScreen.main.bounds.height
    return screenHeight - v.cgRectValue.minY
  }
}
