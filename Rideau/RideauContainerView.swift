//
//  RideauContainerView.swift
//  Rideau
//
//  Created by muukii on 2019/02/06.
//  Copyright © 2019 muukii. All rights reserved.
//

import Foundation

public final class RideauContainerView : UIView {
  
  public let accessibleAreaLayoutGuide: UILayoutGuide = .init()
  public let visibleAreaLayoutGuide: UILayoutGuide = .init()
  
  public weak var currentBodyView: UIView?
  private var previousSizeOfBodyView: CGSize?
  
  var didChangeContent: () -> Void = {}
  
  init() {
    
    super.init(frame: .zero)
    
    visibleAreaLayoutGuide.identifier = "accessibleAreaLayoutGuide"    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func setExpanding(view: UIView) {
    
    currentBodyView?.removeFromSuperview()
    
    addSubview(view)
    
    currentBodyView = view

    view.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      view.topAnchor.constraint(equalTo: visibleAreaLayoutGuide.topAnchor),
      view.rightAnchor.constraint(equalTo: visibleAreaLayoutGuide.rightAnchor),
      view.leftAnchor.constraint(equalTo: visibleAreaLayoutGuide.leftAnchor),
      view.bottomAnchor.constraint(greaterThanOrEqualTo: visibleAreaLayoutGuide.bottomAnchor),
      view.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor),
      ])
    
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
      let top = visibleAreaLayoutGuide.topAnchor.constraint(equalTo: topAnchor)
      let right = visibleAreaLayoutGuide.rightAnchor.constraint(equalTo: rightAnchor)
      let left = visibleAreaLayoutGuide.leftAnchor.constraint(equalTo: leftAnchor)
      let bottom = visibleAreaLayoutGuide.bottomAnchor.constraint(equalTo: owner.bottomAnchor)
      
      NSLayoutConstraint.activate([
        top, right, left, bottom
        ]
        .compactMap { $0 }
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
        ]
        .compactMap { $0 }
      )
    }
    
  }
}
