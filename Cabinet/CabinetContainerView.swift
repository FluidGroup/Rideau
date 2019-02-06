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
  
  private var top: NSLayoutConstraint?
  private var right: NSLayoutConstraint?
  private var left: NSLayoutConstraint?
  private var bottom: NSLayoutConstraint?
  
  init() {
    
    super.init(frame: .zero)
    addLayoutGuide(accessibleAreaLayoutGuide)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func set(owner: CabinetInternalView) {
    
    top = accessibleAreaLayoutGuide.topAnchor.constraint(equalTo: topAnchor)
    right = accessibleAreaLayoutGuide.rightAnchor.constraint(equalTo: rightAnchor)
    left = accessibleAreaLayoutGuide.leftAnchor.constraint(equalTo: leftAnchor)
    bottom = accessibleAreaLayoutGuide.bottomAnchor.constraint(equalTo: owner.bottomAnchor)
    
    NSLayoutConstraint.activate([
      top, right, left, bottom
      ]
      .compactMap { $0 }
    )
  }
}
