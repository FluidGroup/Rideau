//
//  StackCell.swift
//  StackScrollView
//
//  Created by muukii on 5/2/17.
//  Copyright © 2017 muukii. All rights reserved.
//

import Foundation

// MARK: Beta
open class StackCell: UIView, StackCellType {
  
  open var shouldAnimateLayoutChanges: Bool = true
  
  open override func invalidateIntrinsicContentSize() {
    super.invalidateIntrinsicContentSize()
    updateLayout(animated: shouldAnimateLayoutChanges)
  }
}
