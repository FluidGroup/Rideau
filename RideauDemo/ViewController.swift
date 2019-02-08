//
//  ViewController.swift
//  Cabinet
//
//  Created by muukii on 9/22/18.
//  Copyright © 2018 muukii. All rights reserved.
//

import UIKit

import Rideau

class ViewController: UIViewController {

  let cabinetView = CabinetView(frame: .zero) { (config) in
    config.snapPoints = [.pointsFromBottom(120), .fraction(0.4), .fraction(0.8), .fraction(1)]
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    view.addSubview(cabinetView)

    cabinetView.frame = view.bounds
    cabinetView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    let menu = MenuView()
    
    cabinetView.containerView.addSubview(menu)
    cabinetView.isTrackingKeyboard = false
    
    menu.translatesAutoresizingMaskIntoConstraints = false
    menu.button.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      menu.topAnchor.constraint(equalTo: cabinetView.containerView.topAnchor),
      menu.rightAnchor.constraint(equalTo: cabinetView.containerView.rightAnchor),
      menu.bottomAnchor.constraint(equalTo: cabinetView.containerView.bottomAnchor),
      menu.leftAnchor.constraint(equalTo: cabinetView.containerView.leftAnchor),
      
      menu.button.centerXAnchor.constraint(equalTo: cabinetView.containerView.accessibleAreaLayoutGuide.centerXAnchor),
      menu.button.bottomAnchor.constraint(equalTo: cabinetView.containerView.accessibleAreaLayoutGuide.bottomAnchor),

      ])
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print("viewDidAppear")
  }

  @IBAction func didTapShowButton(_ sender: Any) {
    cabinetView.set(snapPoint: .fraction(1), animated: true, completion: {})
  }

  @IBAction func didTapShowModalButton(_ sender: Any) {
    
    let target = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TargetViewController") as! TargetViewController
    
    let controller = CabinetViewController(
      bodyViewController: target,
      configuration: {
        var config = CabinetView.Configuration()
        config.snapPoints = [.hidden, .autoPointsFromBottom, .fraction(1)]
        return config
    }(),
      initialSnapPoint: .autoPointsFromBottom
    )
    
    present(controller, animated: true, completion: nil)
    
  }
}

extension ViewController {

  class MenuView : UIView {
    
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
    
    let button = UIButton(type: .system)

    init() {
      super.init(frame: .zero)

      container.translatesAutoresizingMaskIntoConstraints = false
      addSubview(container)
      
      NSLayoutConstraint.activate([
        container.topAnchor.constraint(equalTo: topAnchor),
        container.rightAnchor.constraint(equalTo: rightAnchor),
        container.bottomAnchor.constraint(equalTo: bottomAnchor),
        container.leftAnchor.constraint(equalTo: leftAnchor),
        ])
      
      container.addSubview(titleView)
      container.addSubview(contentView)
      container.addSubview(button)
      
      button.setTitle("Hello", for: .normal)

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

