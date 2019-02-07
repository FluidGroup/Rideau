//
//  CabinetViewControllerTransitionController.swift
//  Cabinet
//
//  Created by muukii on 2019/02/05.
//  Copyright © 2019 muukii. All rights reserved.
//

import Foundation

public final class CabinetPresentTransitionController : NSObject, UIViewControllerAnimatedTransitioning {
  
  let targetSnapPoint: CabinetSnapPoint
  
  init(targetSnapPoint: CabinetSnapPoint) {
    self.targetSnapPoint = targetSnapPoint
    super.init()
  }
  
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }
  
  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    guard let controller = transitionContext.viewController(forKey: .to) as? CabinetViewController else {
      fatalError()
    }
    
    transitionContext.containerView.addSubview(controller.view)
    
    controller.view.layoutIfNeeded()
    
    transitionContext.completeTransition(true)
    
    controller.backgroundView.backgroundColor = UIColor(white: 0, alpha: 0)
    
    UIView.animate(
      withDuration: 0.4,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 0,
      options: [.beginFromCurrentState],
      animations: {
        controller.backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.2)
    }, completion: nil)
    
    controller.cabinetView.set(snapPoint: targetSnapPoint, animated: true) {
    }
  }
}

public final class CabinetDismissTransitionController : NSObject, UIViewControllerAnimatedTransitioning {
  
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0
  }
  
  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    guard let controller = transitionContext.viewController(forKey: .from) as? CabinetViewController else {
      fatalError()
    }
    
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 0,
      options: [.beginFromCurrentState, .allowUserInteraction],
      animations: {
        controller.backgroundView.backgroundColor = UIColor(white: 0, alpha: 0)
    }, completion: { _ in
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    })
    
    controller.cabinetView.set(snapPoint: .hidden, animated: true) {
    }
  }
}

