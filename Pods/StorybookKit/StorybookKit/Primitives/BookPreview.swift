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

public struct BookPreview<View: UIView>: BookView {

  public var backgroundColor: UIColor = {
    if #available(iOS 13.0, *) {
      return .systemBackground
    } else {
      return .white
    }
  }()

  public let viewBlock: () -> View

  public let declarationIdentifier: DeclarationIdentifier

  private var buttons: ContiguousArray<(title: String, handler: (View) -> Void)> = .init()

  public init(
    _ file: StaticString = #file,
    _ line: UInt = #line,
    _ column: UInt = #column,
    viewBlock: @escaping () -> View
  ) {

    self.viewBlock = viewBlock

    self.declarationIdentifier = .init(
      file: file.description,
      line: line,
      column: column,
      typeName: _typeName(type(of: self))
    )

  }

  public var body: BookView {

    weak var createdView: View?

    return BookGroup {
      _BookPreview(backgroundColor: backgroundColor, viewBlock: {
        let view = self.viewBlock()
        createdView = view
        return view
      })
      if buttons.isEmpty == false {
        BookSpacer(height: 8)
        BookPadding(padding: .init(top: 0, left: 20, bottom: 0, right: 20)) {
          _BookButtons(buttons: ContiguousArray(buttons.map { args in
            (args.0, { args.1(createdView!) })
          }))
        }
      }
      BookCallout(text: """
        \(declarationIdentifier.file):\(declarationIdentifier.line)
        """)
        .font(
          {
            if #available(iOS 13, *) {
              return .monospacedSystemFont(ofSize: 8, weight: .regular)
            } else {
              return .systemFont(ofSize: 8, weight: .regular)
            }
          }())
      BookSpacer(height: 16)
    }
  }

  public func backgroundColor(_ color: UIColor) -> Self {
    modified {
      $0.backgroundColor = color
    }
  }

  public func addButton(_ title: String, handler: @escaping (View) -> Void) -> Self {
    modified {
      $0.buttons.append((title: title, handler: handler))
    }
  }

  public func title(_ text: String) -> BookGroup {
    .init {
      BookSpacer(height: 8)
      BookText(text)
        .font(
          {
            if #available(iOS 13, *) {
              return .monospacedSystemFont(ofSize: 17, weight: .semibold)
            } else {
              return .systemFont(ofSize: 17, weight: .semibold)
            }
          }())
      self
    }
  }
}

/// A component descriptor that just displays UI-Component
fileprivate struct _BookPreview<View: UIView>: BookViewRepresentableType {

  let viewBlock: () -> View

  let backgroundColor: UIColor

  init(backgroundColor: UIColor, viewBlock: @escaping () -> View) {
    self.backgroundColor = backgroundColor
    self.viewBlock = viewBlock
  }

  func makeView() -> UIView {
    let view = _View(element: viewBlock())
    view.backgroundColor = backgroundColor
    return view
  }

  private final class _View : UIView {

    public init() {
      super.init(frame: .zero)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    public convenience init(
      element: UIView,
      insets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
    ) {
      self.init()

      element.translatesAutoresizingMaskIntoConstraints = false
      addSubview(element)

      NSLayoutConstraint.activate([
        element.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
        element.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -insets.right),
        element.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: insets.left),
        element.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
        element.centerXAnchor.constraint(equalTo: centerXAnchor)
      ])
    }

    public convenience init(
      stretchableElement element: UIView,
      insets: UIEdgeInsets = .init(top: 20, left: 16, bottom: 20, right: 16)
    ) {
      self.init()

      element.translatesAutoresizingMaskIntoConstraints = false
      addSubview(element)

      NSLayoutConstraint.activate([
        element.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
        element.rightAnchor.constraint(equalTo: rightAnchor, constant: -insets.right),
        element.leftAnchor.constraint(equalTo: leftAnchor, constant: insets.left),
        element.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
        element.centerXAnchor.constraint(equalTo: centerXAnchor)
      ])
    }
  }

}
