//
//  DemoExpandableView.swift
//  RideauDemo2
//
//  Created by Muukii on 2021/08/08.
//  Copyright © 2021 Hiroshi Kimura. All rights reserved.
//

import Foundation
import MondrianLayout
import Rideau

final class DemoExpandableView: UIView, RideauContentType {

  private var heightConstraint: NSLayoutConstraint!

  init() {
    super.init(frame: .zero)

    heightConstraint = heightAnchor.constraint(equalToConstant: 120)
    heightConstraint.priority = .defaultHigh
    heightConstraint.isActive = true

    let expandButton = UIButton(type: .system)

    expandButton.addTarget(self, action: #selector(expand), for: .touchUpInside)
    expandButton.setTitle("Expand", for: .normal)

    let shrinkButton = UIButton(type: .system)

    shrinkButton.addTarget(self, action: #selector(shrink), for: .touchUpInside)
    shrinkButton.setTitle("Shrink", for: .normal)

    backgroundColor = .systemTeal

    mondrian.buildSubviews {
      ZStackBlock {
        VStackBlock {
          expandButton
          shrinkButton
          StackingSpacer(minLength: 0)
        }
        .background(
          UIView.mock(backgroundColor: .orange).viewBlock.padding(4)
        )
      }
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc private func expand() {
    heightConstraint.constant = 300
    requestRideauSelfSizingUpdate(animator: UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1, animations: nil))
  }

  @objc private func shrink() {
    heightConstraint.constant = 120
    requestRideauSelfSizingUpdate(animator: UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1, animations: nil))
  }

}
