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
  
  public convenience init(_ bodyViewController: UIViewController, config: (inout CabinetView.Configuration) -> Void) {
    
    var configuration = CabinetView.Configuration()
    config(&configuration)
    
    self.init(bodyViewController, configuration: configuration)
            
  }
  
  public init(_ bodyViewController: UIViewController, configuration: CabinetView.Configuration? = nil) {
    self.bodyViewController = bodyViewController
    self.cabinetView = .init(frame: .zero, configuration: configuration)
    
    super.init(nibName: nil, bundle: nil)
    
    self.modalPresentationStyle = .overFullScreen
    self.transitioningDelegate = self
    
    bodyViewController.willMove(toParent: self)
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
    
    cabinetView.translatesAutoresizingMaskIntoConstraints = false
    
    bodyViewController.view.translatesAutoresizingMaskIntoConstraints = false
    cabinetView.containerView.addSubview(bodyViewController.view)
    
    NSLayoutConstraint.activate([
      cabinetView.topAnchor.constraint(equalTo: view.topAnchor),
      cabinetView.rightAnchor.constraint(equalTo: view.rightAnchor),
      cabinetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      cabinetView.leftAnchor.constraint(equalTo: view.leftAnchor),
      
      bodyViewController.view.topAnchor.constraint(equalTo: cabinetView.containerView.topAnchor),
      bodyViewController.view.rightAnchor.constraint(equalTo: cabinetView.containerView.rightAnchor),
      bodyViewController.view.bottomAnchor.constraint(equalTo: cabinetView.containerView.bottomAnchor),
      bodyViewController.view.leftAnchor.constraint(equalTo: cabinetView.containerView.leftAnchor),
      ])
    
    cabinetView.didChangeSnapPoint = { [weak self] point in
      
      guard point == .hidden else {
        return
      }
      self?.view.endEditing(true)
      self?.dismiss(animated: false, completion: nil)
    }
  }
}

extension CabinetViewController : UIViewControllerTransitioningDelegate {
  
  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    return CabinetViewControllerPresentTransitionController(targetSnapPoint: .fraction(1))
  }
  
  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            
    return CabinetViewControllerDismissTransitionController()
  }
     
}
