//
//  CabinetContainerView.swift
//  Cabinet
//
//  Created by muukii on 2019/02/06.
//  Copyright © 2019 muukii. All rights reserved.
//

import Foundation

public final class CabinetContainerView : UIView {
  
  public let accessibleAreaLayoutGuide: UILayoutGuide = .init()
  public let visibleAreaLayoutGuide: UILayoutGuide = .init()
  
  public let expandingView = UIView()
  
  init() {
    
    super.init(frame: .zero)
    
    visibleAreaLayoutGuide.identifier = "accessibleAreaLayoutGuide"
    
    addSubview(expandingView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func setExpanding(view: UIView) {
    
    expandingView.addSubview(view)
    view.setContentCompressionResistancePriority(.required, for: .vertical)
    view.setContentCompressionResistancePriority(.required, for: .horizontal)
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let top = view.topAnchor.constraint(equalTo: expandingView.topAnchor)
    let right = view.rightAnchor.constraint(equalTo: expandingView.rightAnchor)
    let left = view.leftAnchor.constraint(equalTo: expandingView.leftAnchor)
    let bottom = view.bottomAnchor.constraint(equalTo: expandingView.bottomAnchor)
    
    NSLayoutConstraint.activate([
      top, right, left, bottom
      ]
      .compactMap { $0 }
    )
    
  }
  
  func set(owner: CabinetInternalView) {
    
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
    
    expandingView: do {
      expandingView.translatesAutoresizingMaskIntoConstraints = false
      
      let top = expandingView.topAnchor.constraint(equalTo: topAnchor)
      let right = expandingView.rightAnchor.constraint(equalTo: rightAnchor)
      let left = expandingView.leftAnchor.constraint(equalTo: leftAnchor)
      let bottom = expandingView.bottomAnchor.constraint(equalTo: owner.bottomAnchor)
      bottom.priority = .defaultLow
      
      NSLayoutConstraint.activate([
        top, right, left, bottom
        ]
        .compactMap { $0 }
      )
    }
    
  }
}
