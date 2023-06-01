import MondrianLayout
import UIKit

final class ResizingVisualizerView: UIView {

  init() {
    super.init(frame: .zero)

    mondrian.buildSubviews {
      ZStackBlock {
        UIView.mock(backgroundColor: .systemPink)
          .viewBlock
          .overlay(
            UIView.mock(backgroundColor: .systemOrange)
              .viewBlock
              .padding(20)
          )
      }
    }

  }

  required init?(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

}
