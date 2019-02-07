//
//  TouchThroughView.swift
//  Cabinet
//
//  Created by muukii on 9/24/18.
//  Copyright © 2018 muukii. All rights reserved.
//

import UIKit

public class TouchThroughView : UIView {

  public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

    let view = super.hitTest(point, with: event)
    
    if view == self || view?.isDescendant(of: self) == false {

      return nil
    }
    return view
  }
}
