//
// Rideau
//
// Copyright (c) 2019 muukii
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

import UIKit

/// An Object that displays an RideauView with Modal Presentation.
open class RideauViewController : UIViewController {
  
  public let cabinetView: RideauView
  
  public unowned let bodyViewController: UIViewController
  
  private let initialSnapPoint: RideauSnapPoint
  
  let backgroundView: UIView = .init()
  
  public init<T : UIViewController>(
    bodyViewController: T,
    configuration: RideauView.Configuration,
    initialSnapPoint: RideauSnapPoint,
    setup: (RideauContainerView, T) -> Void = { _, _ in }
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
    
    cabinetView.containerView.set(bodyView: bodyViewController.view, options: .strechDependsVisibleArea)
    
    setup(cabinetView.containerView, bodyViewController)
    
    self.modalPresentationStyle = .overFullScreen
    self.transitioningDelegate = self
    
    view.layoutIfNeeded()
    bodyViewController.willMove(toParent: self)
    addChild(bodyViewController)
    
  }
  
  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackdropView))    
    backgroundView.addGestureRecognizer(tap)
  }
  
  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    cabinetView.didChangeSnapPoint = { [weak self] point in
      
      guard point == .hidden else {
        return
      }
      self?.cabinetView.alpha = 0
      self?.view.endEditing(true)
      self?.dismiss(animated: true, completion: nil)
    }
    
  }
  
  @objc private func didTapBackdropView(gesture: UITapGestureRecognizer) {
    self.dismiss(animated: true, completion: nil)
  }
}

extension RideauViewController : UIViewControllerTransitioningDelegate {
  
  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    return RideauPresentTransitionController(targetSnapPoint: initialSnapPoint)
  }
  
  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            
    return RideauDismissTransitionController()
  }
  
//  public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
//
//    return RideauPresentaionController(presentedViewController: presented, presenting: presenting, canCloseBackgroundTap: true)
//  }
  
}
