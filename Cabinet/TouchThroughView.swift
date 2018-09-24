//
//  TouchThroughView.swift
//  Cabinet
//
//  Created by muukii on 9/24/18.
//  Copyright © 2018 muukii. All rights reserved.
//

import UIKit

class TouchThroughView : UIView {

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

    let view = super.hitTest(point, with: event)

    if view == self {

      return nil
    }
    return view
  }
}
