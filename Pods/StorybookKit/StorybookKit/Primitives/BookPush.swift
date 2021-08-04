//
// Copyright (c) 2020 Eureka, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

/// A component descriptor that previewing with push presentation.
public struct BookPush: BookViewRepresentableType {

  public let pushingViewControllerBlock: () -> UIViewController

  public let title: String

  public init(
    title: String,
    pushingViewControllerBlock: @escaping () -> UIViewController
  ) {
    self.title = title
    self.pushingViewControllerBlock = pushingViewControllerBlock
  }

  public func makeView() -> UIView {
    _View(
      title: title,
      pushingViewControllerBlock: pushingViewControllerBlock
    )
  }

  private final class _View: UIView {

    private let pushButton: UIButton
    private let pushingViewControllerBlock: () -> UIViewController

    init(title: String, pushingViewControllerBlock: @escaping () -> UIViewController) {

      self.pushButton = UIButton(type: .system)
      self.pushingViewControllerBlock = pushingViewControllerBlock

      super.init(frame: .zero)

      self.pushButton.setTitle(title + "➡️", for: .normal)
      self.pushButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
      if #available(iOS 13.0, *) {
        self.pushButton.tintColor = .label
      } else {
        self.pushButton.tintColor = .darkText
      }
      self.pushButton.addTarget(self, action: #selector(onTapPushButton), for: .touchUpInside)

      addSubview(pushButton)

      pushButton.translatesAutoresizingMaskIntoConstraints = false

      NSLayoutConstraint.activate([

        pushButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
        pushButton.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -layoutMargins.right),
        pushButton.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: layoutMargins.left),
        pushButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.0),
        pushButton.centerXAnchor.constraint(equalTo: centerXAnchor),

      ])
    }

    public required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func onTapPushButton() {

      let presentingViewControllerCandidate = sequence(first: next, next: { $0?.next }).first { $0 is UIViewController } as? UIViewController

      guard let navigationController = presentingViewControllerCandidate?.navigationController else {
        assertionFailure()
        return
      }

      let viewController = pushingViewControllerBlock()

      navigationController.pushViewController(viewController, animated: true)

    }
  }

}
