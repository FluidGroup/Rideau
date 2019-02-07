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
  
  private let initialSnapPoint: CabinetSnapPoint
  
  let backgroundView: UIView = .init()
  
  public init<T : UIViewController>(
    bodyViewController: T,
    configuration: CabinetView.Configuration,
    initialSnapPoint: CabinetSnapPoint,
    setup: (CabinetContainerView, T) -> Void = { _, _ in }
    ) {
    
    precondition(configuration.snapPoints.contains(initialSnapPoint))
    
    var c = configuration
    
    c.snapPoints.insert(.hidden)
    
    self.initialSnapPoint = initialSnapPoint
    self.bodyViewController = bodyViewController
    self.cabinetView = .init(frame: .zero, configuration: c)
    
    super.init(nibName: nil, bundle: nil)
    
    view.addSubview(backgroundView)
    
    backgroundView.frame = view.bounds
    backgroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    
    view.addSubview(cabinetView)
    cabinetView.frame = view.bounds
    cabinetView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    
    cabinetView.containerView.setExpanding(view: bodyViewController.view)
    
    setup(cabinetView.containerView, bodyViewController)
    
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
    
    cabinetView.didChangeSnapPoint = { [weak self] point in
      
      guard point == .hidden else {
        return
      }
      self?.view.endEditing(true)
      self?.dismiss(animated: true, completion: nil)
    }
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackdropView))
    
    backgroundView.addGestureRecognizer(tap)
  }
  
  @objc private func didTapBackdropView(gesture: UITapGestureRecognizer) {
    self.dismiss(animated: true, completion: nil)
  }
}

extension CabinetViewController : UIViewControllerTransitioningDelegate {
  
  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    return CabinetPresentTransitionController(targetSnapPoint: initialSnapPoint)
  }
  
  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            
    return CabinetDismissTransitionController()
  }
  
//  public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
//
//    return CabinetPresentaionController(presentedViewController: presented, presenting: presenting, canCloseBackgroundTap: true)
//  }
  
}
