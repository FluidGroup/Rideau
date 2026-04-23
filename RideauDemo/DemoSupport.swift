import SwiftUI
import UIKit

struct ViewControllerContainer<Controller: UIViewController>: UIViewControllerRepresentable {
  let make: () -> Controller

  init(_ make: @escaping () -> Controller) {
    self.make = make
  }

  func makeUIViewController(context: Context) -> Controller {
    make()
  }

  func updateUIViewController(_ uiViewController: Controller, context: Context) {}
}

extension UIView {
  static func mockBlock(color: UIColor) -> UIView {
    let view = UIView()
    view.backgroundColor = color
    view.layer.borderWidth = 3
    view.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    return view
  }
}

final class IntrinsicSizeView: UIView {
  private let preferredSize: CGSize

  init(preferredSize: CGSize) {
    self.preferredSize = preferredSize
    super.init(frame: .zero)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError()
  }

  override var intrinsicContentSize: CGSize { preferredSize }
}
