
import MondrianLayout

final class DemoContentViewController: UIViewController {

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    var v = ListContentView()
    v.onTapButton = { [unowned self] in
      let modal = ModalViewController()

      self.present(modal, animated: true, completion: nil)
    }

    let contentView = SwiftUIWrapperView.init(content: v)

    view.mondrian.buildSubviews {
      ZStackBlock(alignment: .attach(.all)) {
        contentView
      }
    }
  }

}

private final class ModalViewController: UIViewController {

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    var v = ListContentView()
    v.onTapButton = { [unowned self] in
      self.dismiss(animated: true, completion: nil)
    }

    let contentView = SwiftUIWrapperView.init(content: v)

    view.mondrian.buildSubviews {
      ZStackBlock(alignment: .attach(.all)) {
        contentView
      }
    }
  }

}
