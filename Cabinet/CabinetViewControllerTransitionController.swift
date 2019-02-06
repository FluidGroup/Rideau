//
//  CabinetViewControllerTransitionController.swift
//  Cabinet
//
//  Created by muukii on 2019/02/05.
//  Copyright © 2019 muukii. All rights reserved.
//

import Foundation

public final class CabinetViewControllerPresentTransitionController : NSObject, UIViewControllerAnimatedTransitioning {
  
  let targetSnapPoint: SnapPoint
  
  init(targetSnapPoint: SnapPoint) {
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

    controller.cabinetView.set(snapPoint: targetSnapPoint, animated: true) {
    }
  }
}

public final class CabinetViewControllerDismissTransitionController : NSObject, UIViewControllerAnimatedTransitioning {
  
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }
  
  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    guard let controller = transitionContext.viewController(forKey: .from) as? CabinetViewController else {
      fatalError()
    }
    
    controller.cabinetView.set(snapPoint: .hidden, animated: true) {
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
    
  }
}

