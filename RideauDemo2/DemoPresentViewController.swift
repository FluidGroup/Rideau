import Foundation
import MondrianLayout
import Rideau
import UIKit

final class DemoPresentViewController: UIViewController {

  private let rideauView: RideauView

  private let presentButton: UIButton = .init(type: .system)

  private var _present: () -> Void = {}

  init(
    snapPoints: Set<RideauSnapPoint>,
    resizingOption: RideauContentContainerView.ResizingOption,
    contentView: UIView
  ) {

    self.rideauView = RideauView(frame: .zero) { (config) in
      config.snapPoints = snapPoints
    }

    super.init(nibName: nil, bundle: nil)

    presentButton.addTarget(self, action: #selector(onTapPresentButton), for: .touchUpInside)
    presentButton.setTitle("Present", for: .normal)

    view.backgroundColor = .white

    view.mondrian.buildSubviews {
      ZStackBlock {
        presentButton
      }
    }

    _present = { [unowned self] in

      let controller = RideauViewController(
        bodyViewController: RideauWrapperViewController(view: contentView),
        configuration: .init {
          $0.snapPoints = [.hidden, .fraction(0.4), .fraction(1)]
        },
        initialSnapPoint: .fraction(0.4),
        resizingOption: resizingOption,
        backdropColor: .init(white: 0, alpha: 0.5),
        usesDismissalPanGestureOnBackdropView: true
      )

      self.present(controller, animated: true, completion: nil)

    }

  }

  required init?(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

  }

  @objc private func onTapPresentButton() {
    _present()
  }

}
