//
//  ViewController.swift
//  Cabinet
//
//  Created by muukii on 9/22/18.
//  Copyright © 2018 muukii. All rights reserved.
//

import UIKit

import Cabinet

class ViewController: UIViewController {

  let cabinetView = CabinetView()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    view.addSubview(cabinetView)

    cabinetView.frame = view.bounds
    cabinetView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    let menu = MenuView()

    cabinetView.configuration.snapPoints = [.fraction(0.2), .fraction(0.6), .fraction(0.8), .pointsFromSafeAreaTop(20)]
    cabinetView.set(contentView: menu)
  
  }

  @IBAction func didTapShowButton(_ sender: Any) {
    cabinetView.set(snapPoint: .fraction(1))
  }

}

extension ViewController {

  class MenuView : UIView, CabinetContentViewType {

    var headerView: UIView? {
      return titleView
    }

    var bodyView: UIView? {
      return contentView
    }

    var scrollViews: [UIScrollView] {
      return []
    }

    let titleView = UIView()

    let contentView = UIView()

    let container = UIView()

    init() {
      super.init(frame: .zero)

      addSubview(container)
      container.addSubview(titleView)
      container.addSubview(contentView)

      container.autoresizingMask = [.flexibleHeight, .flexibleWidth]

      titleView.translatesAutoresizingMaskIntoConstraints = false
      contentView.translatesAutoresizingMaskIntoConstraints = false

      titleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
      titleView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
      titleView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
      titleView.heightAnchor.constraint(equalToConstant: 55).isActive = true

      contentView.topAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
      contentView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
      contentView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

      titleView.backgroundColor = UIColor(red:0.43, green:0.49, blue:0.59, alpha:1.00)
      contentView.backgroundColor = UIColor(red:0.26, green:0.33, blue:0.45, alpha:1.00)
      container.backgroundColor = UIColor(red:0.15, green:0.21, blue:0.33, alpha:1.00)

      container.layer.cornerRadius = 8
      container.layer.masksToBounds = true

      layer.cornerRadius = 8
      layer.shadowColor = UIColor(white: 0, alpha: 0.2).cgColor
      layer.shadowOpacity = 1
      layer.shadowOffset = CGSize(width: 0, height: 0)
      layer.shadowRadius = 4

    }

    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
}

