import Rideau
import UIKit

final class DemoPresentViewController: UIViewController {
  private let snapPoints: Set<RideauSnapPoint>
  private let initialSnapPoint: RideauSnapPoint
  private let resizingOption: RideauContentContainerView.ResizingOption
  private let contentView: UIView

  init(
    snapPoints: Set<RideauSnapPoint>,
    initialSnapPoint: RideauSnapPoint,
    resizingOption: RideauContentContainerView.ResizingOption,
    contentView: UIView
  ) {
    self.snapPoints = snapPoints
    self.initialSnapPoint = initialSnapPoint
    self.resizingOption = resizingOption
    self.contentView = contentView
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    let button = UIButton(type: .system)
    button.setTitle("Present", for: .normal)
    button.titleLabel?.font = .preferredFont(forTextStyle: .title2)
    button.addTarget(self, action: #selector(onTapPresent), for: .touchUpInside)

    button.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(button)
    NSLayoutConstraint.activate([
      button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
  }

  @objc private func onTapPresent() {
    let controller = RideauViewController(
      bodyViewController: RideauWrapperViewController(view: contentView),
      configuration: .init { config in
        config.snapPoints = snapPoints
      },
      initialSnapPoint: initialSnapPoint,
      resizingOption: resizingOption,
      backdropColor: UIColor(white: 0, alpha: 0.5),
      usesDismissalPanGestureOnBackdropView: true
    )
    present(controller, animated: true)
  }
}
