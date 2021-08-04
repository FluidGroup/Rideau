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

public struct BookSpacer: BookViewRepresentableType {

  private let height: CGFloat

  public init(height: CGFloat) {
    self.height = height
  }

  public func makeView() -> UIView {
    _View(height: height)
  }

  private final class _View: UIView {

    init(height: CGFloat) {
      super.init(frame: .zero)

      self.translatesAutoresizingMaskIntoConstraints = false

      heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

  }

}

public struct BookPadding<Content: BookViewRepresentableType>: BookViewRepresentableType {

  public let padding: UIEdgeInsets
  private let content: Content

  public init(padding: UIEdgeInsets, content: () -> Content) {
    self.padding = padding
    self.content = content()
  }

  public func makeView() -> UIView {
    PaddingView(padding: padding, bodyView: content.makeView())
  }
}

extension BookViewRepresentableType {

  public func padding(_ insets: UIEdgeInsets) -> BookPadding<Self> {
    .init(padding: insets, content: { self })
  }

}

final class PaddingView<Body: UIView>: UIView {

  let body: Body

  ///
  ///
  /// - Parameters:
  ///   - padding: if you no needs padding, use .infinity.
  ///   - bodyView: Embedded view
  init(padding: UIEdgeInsets, bodyView: Body) {

    self.body = bodyView

    super.init(frame: .zero)

    bodyView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(bodyView)

    if padding.top.isFinite {
      bodyView.topAnchor.constraint(equalTo: topAnchor, constant: padding.top).isActive = true
    } else {
      bodyView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
    }

    if padding.right.isFinite {
      bodyView.rightAnchor.constraint(equalTo: rightAnchor, constant: -padding.right).isActive = true
    } else {
      bodyView.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor).isActive = true
    }

    if padding.left.isFinite {
      bodyView.leftAnchor.constraint(equalTo: leftAnchor, constant: padding.left).isActive = true
    } else {
      bodyView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor).isActive = true
    }

    if padding.bottom.isFinite {
      bodyView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding.bottom).isActive = true
    } else {
      bodyView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true
    }

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

