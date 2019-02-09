//
//  RideauContainerView.swift
//  Rideau
//
//  Created by muukii on 2019/02/06.
//  Copyright © 2019 muukii. All rights reserved.
//

import Foundation

public protocol RideauContainerBodyType {
  
}

extension RideauContainerBodyType where Self : UIView {
  
  public func requestUpdateLayout() {
    guard let containerView = self.superview as? RideauContainerView else { return }
    containerView.requestUpdateLayout()
  }
}

extension RideauContainerBodyType where Self : UIViewController {
  
  public func requestUpdateLayout() {
    guard let containerView = self.view.superview as? RideauContainerView else { return }
    containerView.requestUpdateLayout()
  }
}

/// Main view
/// This view will be translated with user interaction.
/// Frame.size.height will be set maximum SnapPoint.
/// plus, Frame.size will not change.
public final class RideauContainerView : UIView {
  
  public enum SizingOption {
    case strechDependsVisibleArea
    case noStretch
  }
  
  public let accessibleAreaLayoutGuide: UILayoutGuide = .init()
  public let visibleAreaLayoutGuide: UILayoutGuide = .init()
  
  public weak var currentBodyView: UIView?
  private var previousSizeOfBodyView: CGSize?
  
  var didChangeContent: () -> Void = {}
  
  // MARK: - Initializers
  
  init() {
    
    super.init(frame: .zero)
    
    visibleAreaLayoutGuide.identifier = "accessibleAreaLayoutGuide"    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Functions
  
  public func requestUpdateLayout() {
    didChangeContent()
  }
  
  @available(*, unavailable, message: "Don't add view directory, use set(bodyView: options:)")
  public override func addSubview(_ view: UIView) {
    assertionFailure("Don't add view directory, use set(bodyView: options:)")
    super.addSubview(view)
  }
  
  public func set(bodyView: UIView, options: SizingOption) {
    
    currentBodyView?.removeFromSuperview()
    super.addSubview(bodyView)
    currentBodyView = bodyView
    bodyView.translatesAutoresizingMaskIntoConstraints = false
    
    switch options {
    case .noStretch:
      
      NSLayoutConstraint.activate([
        bodyView.topAnchor.constraint(equalTo: topAnchor),
        bodyView.rightAnchor.constraint(equalTo: rightAnchor),
        bodyView.leftAnchor.constraint(equalTo: leftAnchor),
        bodyView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
      
    case .strechDependsVisibleArea:
      
      NSLayoutConstraint.activate([
        bodyView.topAnchor.constraint(equalTo: visibleAreaLayoutGuide.topAnchor),
        bodyView.rightAnchor.constraint(equalTo: visibleAreaLayoutGuide.rightAnchor),
        bodyView.leftAnchor.constraint(equalTo: visibleAreaLayoutGuide.leftAnchor),
        bodyView.bottomAnchor.constraint(greaterThanOrEqualTo: visibleAreaLayoutGuide.bottomAnchor),
        bodyView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor),
        ])
      
    }
    
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    if previousSizeOfBodyView != currentBodyView?.bounds.size {
      previousSizeOfBodyView = currentBodyView?.bounds.size
      didChangeContent()
    }
  }
  
  func set(owner: RideauInternalView) {
    
    addLayoutGuide(accessibleAreaLayoutGuide)
    addLayoutGuide(visibleAreaLayoutGuide)
    
    visible: do {
      
      NSLayoutConstraint.activate([
        visibleAreaLayoutGuide.topAnchor.constraint(equalTo: topAnchor),
        visibleAreaLayoutGuide.rightAnchor.constraint(equalTo: rightAnchor),
        visibleAreaLayoutGuide.leftAnchor.constraint(equalTo: leftAnchor),
        visibleAreaLayoutGuide.bottomAnchor.constraint(equalTo: owner.bottomAnchor),
        ]
      )
    }
    
    accessible: do {
      let top = accessibleAreaLayoutGuide.topAnchor.constraint(equalTo: topAnchor)
      let right = accessibleAreaLayoutGuide.rightAnchor.constraint(equalTo: rightAnchor)
      let left = accessibleAreaLayoutGuide.leftAnchor.constraint(equalTo: leftAnchor)
      let bottom: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        bottom = accessibleAreaLayoutGuide.bottomAnchor.constraint(equalTo: owner.safeAreaLayoutGuide.bottomAnchor)
      } else {
        bottom = accessibleAreaLayoutGuide.bottomAnchor.constraint(equalTo: owner.bottomAnchor)
      }
      
      NSLayoutConstraint.activate([
        top, right, left, bottom
        ])
    }
    
  }
}
