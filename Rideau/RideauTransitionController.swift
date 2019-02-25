//
// Rideau
//
// Copyright © 2019 Hiroshi Kimura
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public final class RideauPresentTransitionController : NSObject, UIViewControllerAnimatedTransitioning {
  
  let targetSnapPoint: RideauSnapPoint
  
  init(targetSnapPoint: RideauSnapPoint) {
    self.targetSnapPoint = targetSnapPoint
    super.init()
  }
  
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }
  
  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    guard let controller = transitionContext.viewController(forKey: .to) as? RideauViewController else {
      fatalError()
    }
    
    transitionContext.containerView.addSubview(controller.view)
    
    transitionContext.containerView.layoutIfNeeded()
    
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
    
    controller.rideauView.move(to: targetSnapPoint, animated: true) {
    }
  }
}

public final class RideauDismissTransitionController : NSObject, UIViewControllerAnimatedTransitioning {
  
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0
  }
  
  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    guard let controller = transitionContext.viewController(forKey: .from) as? RideauViewController else {
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
    
    controller.rideauView.move(to: .hidden, animated: true) {
    }
  }
}

