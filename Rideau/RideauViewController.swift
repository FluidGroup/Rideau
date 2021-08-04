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

import UIKit

/// An Object that displays an RideauView with Presentation.
open class RideauViewController: UIViewController {

  // MARK: - Properties

  public var onWillDismiss: () -> Void = {}

  public let rideauView: RideauView

  private let initialSnapPoint: RideauSnapPoint

  let backgroundView: UIView = .init()

  private let backgroundColor: UIColor

  // MARK: - Initializers

  public init<T: UIViewController>(
    bodyViewController: T,
    configuration: RideauView.Configuration,
    initialSnapPoint: RideauSnapPoint,
    resizingOption: RideauContentContainerView.ResizingOption,
    backdropColor: UIColor = UIColor(white: 0, alpha: 0.2),
    usesDismissalPanGestureOnBackdropView: Bool = true
  ) {

    precondition(configuration.snapPoints.contains(initialSnapPoint))

    var c = configuration

    c.snapPoints.insert(.hidden)

    self.initialSnapPoint = initialSnapPoint
    self.rideauView = .init(frame: .zero, configuration: c)

    self.backgroundColor = backdropColor

    super.init(nibName: nil, bundle: nil)

    self.modalPresentationStyle = .overFullScreen
    self.transitioningDelegate = self

    do {

      if usesDismissalPanGestureOnBackdropView {

        let pan = UIPanGestureRecognizer()

        backgroundView.addGestureRecognizer(pan)

        rideauView.register(other: pan)

      }

    }

    do {
      let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackdropView))
      backgroundView.addGestureRecognizer(tap)

      view.addSubview(backgroundView)

      backgroundView.frame = view.bounds
      backgroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

      view.addSubview(rideauView)
      rideauView.frame = view.bounds
      rideauView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

      // To create resolveConfiguration
      view.layoutIfNeeded()

      set(bodyViewController: bodyViewController, to: rideauView, resizingOption: resizingOption)

      view.layoutIfNeeded()
    }
  }

  @available(*, unavailable)
  public required init?(
    coder aDecoder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  open func set(bodyViewController: UIViewController, to rideauView: RideauView, resizingOption: RideauContentContainerView.ResizingOption) {
    bodyViewController.willMove(toParent: self)
    addChild(bodyViewController)
    rideauView.containerView.set(bodyView: bodyViewController.view, resizingOption: resizingOption)
  }

  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    rideauView.handlers.willChangeSnapPoint = { [weak self] point in
      guard point == .hidden else {
        return
      }

      // Temporary
      UIView.animate(
        withDuration: 0.3,
        delay: 0,
        usingSpringWithDamping: 1,
        initialSpringVelocity: 0,
        options: [.beginFromCurrentState, .allowUserInteraction],
        animations: {
          self?.backgroundView.backgroundColor = UIColor(white: 0, alpha: 0)
        },
        completion: { _ in

        }
      )

    }

    rideauView.handlers.didChangeSnapPoint = { [weak self] point in

      guard point == .hidden else {
        return
      }
      self?.dismiss(animated: true, completion: nil)
    }

  }

  @objc private dynamic func didTapBackdropView(gesture: UITapGestureRecognizer) {
    self.dismiss(animated: true, completion: nil)
  }
}

extension RideauViewController: UIViewControllerTransitioningDelegate {

  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

    return RideauPresentTransitionController(targetSnapPoint: initialSnapPoint, backgroundColor: backgroundColor)
  }

  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

    // WORKAROUND: Currently, we can not get the timing of beginning dismissal.
    onWillDismiss()
    return RideauDismissTransitionController()
  }

}


open class RideauWrapperViewController: UIViewController {

  private let _view: UIView

  public init(view: UIView) {
    self._view = view
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func loadView() {
    self.view = _view
  }

}
