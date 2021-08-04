import Foundation
import MondrianLayout
import Rideau
import UIKit

final class DemoInlineViewController: UIViewController {

  private let rideauView = RideauView(frame: .zero) { (config) in
    config.snapPoints = [.autoPointsFromBottom, .fraction(1)]
  }

  init(
    contentView: UIView
  ) {
    super.init(nibName: nil, bundle: nil)

    view.mondrian.buildSubviews {
      ZStackBlock {
        rideauView
      }
    }

    rideauView.containerView.set(
      bodyView: contentView,
      resizingOption: .resizeToVisibleArea
    )

  }

  required init?(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

  }

}
