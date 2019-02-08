//
//  RideauPresentationController.swift
//  Rideau
//
//  Created by muukii on 2019/02/07.
//  Copyright © 2019 muukii. All rights reserved.
//

import Foundation

final class RideauPresentaionController : UIPresentationController {
  
  let dimmingView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 0, alpha: 0.2)
    return view
  }()
  
  private let canCloseBackgroundTap: Bool
  
  init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, canCloseBackgroundTap: Bool? = nil) {
    
    self.canCloseBackgroundTap = canCloseBackgroundTap ?? true
    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
  }
  
  deinit {

  }
  
  override func presentationTransitionWillBegin() {
    
    guard let containerView = self.containerView else { return }
    guard let presentedView = self.presentedView else { return }
    
    if canCloseBackgroundTap {
      let gesture = UITapGestureRecognizer(target: self, action: #selector(tapDimmingView(_:)))
      dimmingView.addGestureRecognizer(gesture)
    }
    
    containerView.addSubview(dimmingView)
    containerView.addSubview(presentedView)
    
    dimmingView.frame = containerView.bounds
    dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    let bottomMargin = UILayoutGuide()
    
    containerView.addLayoutGuide(bottomMargin)
  
    dimmingView.alpha = 0
    
    // Fade in the dimming view alongside the transition
    if let transitionCoordinator = self.presentingViewController.transitionCoordinator {
      transitionCoordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
        self.dimmingView.alpha = 1.0
      }, completion: nil)
    }
  }
  
  override func presentationTransitionDidEnd(_ completed: Bool) {
    if !completed {
      self.dimmingView.removeFromSuperview()
    }
  }
  
  override func dismissalTransitionWillBegin() {
    // Fade out the dimming view alongside the transition
    if let transitionCoordinator = self.presentingViewController.transitionCoordinator {
      transitionCoordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
        self.dimmingView.alpha = 0.0
      }, completion: nil)
    }
  }
  
  override func dismissalTransitionDidEnd(_ completed: Bool) {
    // If the dismissal completed, remove the dimming view
    if completed {
      self.dimmingView.removeFromSuperview()
    }
  }
  
  override func containerViewWillLayoutSubviews() {

  }
  
  override func containerViewDidLayoutSubviews() {
    // Temporary
    // To lay out based on in-call status.
    containerView?.frame = presentingViewController.view.frame
  }
  
  @objc dynamic private func tapDimmingView(_ sender: AnyObject) {
    
    self.containerView?.endEditing(true)
    self.presentedViewController.dismiss(animated: true, completion: nil)
  }
  
}
