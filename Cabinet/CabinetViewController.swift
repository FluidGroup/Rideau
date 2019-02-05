//
//  CabinetViewController.swift
//  Cabinet
//
//  Created by muukii on 2019/02/05.
//  Copyright © 2019 muukii. All rights reserved.
//

import Foundation

open class CabinetViewController : UIViewController {
  
  public let cabinetView: CabinetView
  
  public unowned let bodyViewController: UIViewController
  
  public init(_ bodyViewController: UIViewController) {
    self.bodyViewController = bodyViewController
    self.cabinetView = .init()
    
    super.init(nibName: nil, bundle: nil)
    
    addChild(bodyViewController)
    
  }
  
  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(cabinetView)
    cabinetView.frame = view.bounds
    cabinetView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    
  }
}
