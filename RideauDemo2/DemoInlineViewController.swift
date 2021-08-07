import Foundation
import MondrianLayout
import Rideau
import UIKit

final class DemoInlineViewController: UIViewController {

  private let rideauView: RideauView

  init(
    makeConfiguration: (inout RideauView.Configuration) -> Void,
    resizingOption: RideauContentContainerView.ResizingOption,
    contentView: UIView
  ) {

    self.rideauView = RideauView(configuration: .init(modify: makeConfiguration))

    super.init(nibName: nil, bundle: nil)

    view.backgroundColor = .init(white: 0.7, alpha: 1)

    view.mondrian.buildSubviews {
      ZStackBlock {
        rideauView
          .viewBlock
          .alignSelf(.attach(.all))
      }
    }

    rideauView.containerView.set(
      bodyView: contentView,
      resizingOption: resizingOption
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
