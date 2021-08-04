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

/// A component descriptor that just displays UI-Component
public struct BookPresent: BookViewRepresentableType {

  public let presentedViewControllerBlock: () -> UIViewController

  public let title: String

  public init(
    title: String,
    presentingViewControllerBlock: @escaping () -> UIViewController
  ) {
    self.title = title
    self.presentedViewControllerBlock = presentingViewControllerBlock
  }

  public func makeView() -> UIView {
    _View(
      title: title,
      presentedViewControllerBlock: presentedViewControllerBlock
    )
  }

  private final class _View: UIView {

    private let presentButton: UIButton
    private let presentedViewControllerBlock: () -> UIViewController

    public init(title: String, presentedViewControllerBlock: @escaping () -> UIViewController) {

      self.presentButton = UIButton(type: .system)
      self.presentedViewControllerBlock = presentedViewControllerBlock

      super.init(frame: .zero)

      self.presentButton.setTitle(title + "⬆️", for: .normal)
      self.presentButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
      if #available(iOS 13.0, *) {
        self.presentButton.tintColor = .label
      } else {
        self.presentButton.tintColor = .darkText
      }
      self.presentButton.addTarget(self, action: #selector(onTapPresentButton), for: .touchUpInside)

      addSubview(presentButton)

      presentButton.translatesAutoresizingMaskIntoConstraints = false

      NSLayoutConstraint.activate([

        presentButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
        presentButton.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -layoutMargins.right),
        presentButton.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: layoutMargins.left),
        presentButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.0),
        presentButton.centerXAnchor.constraint(equalTo: centerXAnchor),

      ])
    }

    public required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func onTapPresentButton() {

      let presentingViewControllerCandidate = sequence(first: next, next: { $0?.next }).first { $0 is UIViewController } as? UIViewController

      guard let presentingViewController = presentingViewControllerCandidate else {
        assertionFailure()
        return
      }

      let viewController = presentedViewControllerBlock()

      presentingViewController.present(viewController, animated: true, completion: nil)

    }
  }

}
