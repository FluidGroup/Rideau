//
//  ViewController.swift
//  Cabinet
//
//  Created by muukii on 9/22/18.
//  Copyright © 2018 muukii. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    let cabinetView = CabinetView()

    view.addSubview(cabinetView)

    cabinetView.frame = view.bounds
    cabinetView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

  }


}

