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

#if false

final class RideauPresentationController : UIPresentationController {
  
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

#endif
