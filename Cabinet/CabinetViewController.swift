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
    
    view.addSubview(cabinetView)
    cabinetView.translatesAutoresizingMaskIntoConstraints = false
    
    bodyViewController.view.translatesAutoresizingMaskIntoConstraints = false
    cabinetView.containerView.addSubview(bodyViewController.view)
    
    setup(cabinetView.containerView, bodyViewController)
    
    NSLayoutConstraint.activate([
      cabinetView.topAnchor.constraint(equalTo: view.topAnchor),
      cabinetView.rightAnchor.constraint(equalTo: view.rightAnchor),
      cabinetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      cabinetView.leftAnchor.constraint(equalTo: view.leftAnchor),
      
      bodyViewController.view.topAnchor.constraint(equalTo: cabinetView.containerView.accessibleAreaLayoutGuide.topAnchor),
      bodyViewController.view.rightAnchor.constraint(equalTo: cabinetView.containerView.accessibleAreaLayoutGuide.rightAnchor),
      bodyViewController.view.bottomAnchor.constraint(equalTo: cabinetView.containerView.accessibleAreaLayoutGuide.bottomAnchor),
      bodyViewController.view.leftAnchor.constraint(equalTo: cabinetView.containerView.accessibleAreaLayoutGuide.leftAnchor),
      ])
    
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
    
    view.addGestureRecognizer(tap)
  }
  
  @objc private func didTapBackdropView() {
    cabinetView.set(snapPoint: .hidden, animated: true) {
      self.dismiss(animated: true, completion: nil)
      self.view.endEditing(true)
    }
  }
}

extension CabinetViewController : UIViewControllerTransitioningDelegate {
  
  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    return CabinetViewControllerPresentTransitionController(targetSnapPoint: initialSnapPoint)
  }
  
  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            
    return CabinetViewControllerDismissTransitionController()
  }
     
}
