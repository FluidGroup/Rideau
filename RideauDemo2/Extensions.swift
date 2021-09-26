import UIKit
extension UIView {

  static func mock(backgroundColor: UIColor = .layeringColor) -> UIView {
    let view = UIView()
    view.backgroundColor = backgroundColor
    view.layer.borderWidth = 3
    view.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    return view
  }

  static func mock(backgroundColor: UIColor = .layeringColor, preferredSize: CGSize) -> UIView {
    let view = IntrinsicSizeView(preferredSize: preferredSize)
    view.backgroundColor = backgroundColor
    view.layer.borderWidth = 3
    view.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    return view
  }
}

extension UIColor {

  static var layeringColor: UIColor {
    return .init(white: 0, alpha: 0.2)
  }
}


final class IntrinsicSizeView: UIView {

  private let preferredSize: CGSize

  init(
    preferredSize: CGSize
  ) {
    self.preferredSize = preferredSize
    super.init(frame: .zero)
  }

  required init?(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  override var intrinsicContentSize: CGSize {
    preferredSize
  }

}
