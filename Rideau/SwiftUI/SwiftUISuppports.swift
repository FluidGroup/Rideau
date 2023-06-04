import UIKit

enum SwiftUISupports {
  final class RideauHostingController: UIViewController {

    // MARK: - Properties

    var onWillDismiss: () -> Void = {}
    var onDidDismiss: () -> Void = {}

    let rideauView: RideauView

    let backgroundView: UIView = .init()

    let backgroundColor: UIColor

    private let bodyViewController: UIViewController
    private let resizingOption: RideauContentContainerView.ResizingOption
    private let hidesByBackgroundTouch: Bool
    private let onViewDidAppear: @MainActor (RideauHostingController) -> Void

    // MARK: - Initializers

    init(
      bodyViewController: UIViewController,
      configuration: RideauView.Configuration,
      resizingOption: RideauContentContainerView.ResizingOption,
      backdropColor: UIColor = UIColor(white: 0, alpha: 0.2),
      usesDismissalPanGestureOnBackdropView: Bool = true,
      hidesByBackgroundTouch: Bool = true,
      onViewDidAppear: @escaping @MainActor (RideauHostingController) -> Void
    ) {

      self.hidesByBackgroundTouch = hidesByBackgroundTouch
      self.bodyViewController = bodyViewController
      self.resizingOption = resizingOption
      self.onViewDidAppear = onViewDidAppear

      var c = configuration

      c.snapPoints.insert(.hidden)

      self.rideauView = .init(frame: .zero, configuration: c)

      self.backgroundColor = backdropColor

      super.init(nibName: nil, bundle: nil)

      self.backgroundView.backgroundColor = .clear

      do {

        if usesDismissalPanGestureOnBackdropView {

          let pan = UIPanGestureRecognizer()

          backgroundView.addGestureRecognizer(pan)

          rideauView.register(other: pan)

        }

      }

    }

    @available(*, unavailable)
    required init?(
      coder aDecoder: NSCoder
    ) {
      fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions

    override func viewDidLoad() {
      super.viewDidLoad()

      do {

        if hidesByBackgroundTouch {
          let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackdropView))
          backgroundView.addGestureRecognizer(tap)
        }

        view.addSubview(backgroundView)

        view.backgroundColor = .clear

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

      rideauView.handlers.willMoveTo = { [weak self] point in

        guard let self else { return }

        guard point == .hidden else {

          UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
            self.backgroundView.backgroundColor = self.backgroundColor
          }
          .startAnimation()

          return
        }

        UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
          self.backgroundView.backgroundColor = .clear
        }
        .startAnimation()

      }

      rideauView.handlers.didMoveTo = { [weak self] point in

        guard let self = self else { return }

        guard point == .hidden else {
          return
        }

        self.onWillDismiss()
        self.onDidDismiss()

      }

    }

    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      onViewDidAppear(self)
    }

    func set(
      bodyViewController: UIViewController,
      to rideauView: RideauView,
      resizingOption: RideauContentContainerView.ResizingOption
    ) {
      bodyViewController.willMove(toParent: self)
      addChild(bodyViewController)
      rideauView.containerView.set(bodyView: bodyViewController.view, resizingOption: resizingOption)
    }

    @objc private dynamic func didTapBackdropView(gesture: UITapGestureRecognizer) {

      rideauView.move(to: .hidden, animated: true, completion: {})

    }
  }

}
