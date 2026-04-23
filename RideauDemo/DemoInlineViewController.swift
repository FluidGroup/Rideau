import Rideau
import UIKit

final class DemoInlineViewController: UIViewController {
  private let rideauView: RideauView
  private let contentView: UIView
  private let resizingOption: RideauContentContainerView.ResizingOption

  init(
    snapPoints: Set<RideauSnapPoint>,
    allowsBouncing: Bool = false,
    scrollViewDetection: RideauView.Configuration.ScrollViewOption.ScrollViewDetection = .automatic,
    resizingOption: RideauContentContainerView.ResizingOption,
    contentView: UIView
  ) {
    self.rideauView = RideauView(
      configuration: .init { config in
        config.snapPoints = snapPoints
        config.scrollViewOption.allowsBouncing = allowsBouncing
        config.scrollViewOption.scrollViewDetection = scrollViewDetection
      }
    )
    self.contentView = contentView
    self.resizingOption = resizingOption
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor(white: 0.7, alpha: 1)

    rideauView.handlers.willMoveTo = { print("WillMoveTo \($0)") }
    rideauView.handlers.didMoveTo = { print("DidMoveTo \($0)") }

    rideauView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(rideauView)
    NSLayoutConstraint.activate([
      rideauView.topAnchor.constraint(equalTo: view.topAnchor),
      rideauView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      rideauView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      rideauView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])

    rideauView.containerView.set(
      bodyView: contentView,
      resizingOption: resizingOption
    )
  }
}
