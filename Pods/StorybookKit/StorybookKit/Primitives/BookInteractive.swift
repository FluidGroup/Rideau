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

/// A component descriptor that can control a UI-Component with specified button.
// TODO: Integrate BookDisplay
struct _BookButtons: BookViewRepresentableType {

  private var buttons: ContiguousArray<(title: String, handler: () -> Void)> = .init()

  init(buttons: ContiguousArray<(title: String, handler: () -> Void)>) {
    self.buttons = buttons
  }

  func makeView() -> UIView {
    let view = _View(
      actionDiscriptors: buttons.map {
        _View.ActionDescriptor(title: $0.title, action: $0.handler)
    })
    return view
  }

}

fileprivate final class _View : UIView {

  // MARK: - Properties

  private let stackView: UIStackView = .init()

  // MARK: - Initializers

  public init(actionDiscriptors: [ActionDescriptor]) {

    super.init(frame: .zero)

    stack: do {

      stackView.distribution = .equalSpacing
      stackView.spacing = 8
      stackView.axis = .horizontal
      stackView.alignment = .fill
      stackView.setContentHuggingPriority(.defaultHigh, for: .vertical)

      actionDiscriptors.forEach { descriptor in

        let button = ActionButton(type: .system)

        button.setTitle(descriptor.title, for: .normal)
        button.addTarget(self, action: #selector(actionButtonTouchUpInside), for: .touchUpInside)
        button.action = {
          descriptor.action()
        }

        stackView.addArrangedSubview(button)

      }

    }

    addSubview(stackView)

    stackView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.rightAnchor.constraint(equalTo: rightAnchor),
      stackView.leftAnchor.constraint(equalTo: leftAnchor),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])

  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc
  private func actionButtonTouchUpInside(button: ActionButton) {
    button.action()
  }

  // MARK: - Nested types

  private final class ActionButton : UIButton {
    var action: () -> Void = {}
  }

}

extension _View {

  struct ActionDescriptor {

    // MARK: - Properties
    let title: String

    let action: () -> Void

    // MARK: - Initializers

    init(title: String, action: @escaping () -> Void) {

      self.title = title
      self.action = action
    }
  }

}
