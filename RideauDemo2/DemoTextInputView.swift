//
//  DemoTextInputView.swift
//  RideauDemo2
//
//  Created by Muukii on 2021/08/08.
//  Copyright © 2021 Hiroshi Kimura. All rights reserved.
//

import Foundation

import Foundation
import MondrianLayout
import Rideau

final class DemoTextInputView: UIView {

  init() {
    super.init(frame: .zero)

    mondrian.buildSubviews {
      ZStackBlock {
        UIView.mock(backgroundColor: .systemPurple)

        UITextView()
          .viewBlock
          .padding(30)
      }
    }

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
