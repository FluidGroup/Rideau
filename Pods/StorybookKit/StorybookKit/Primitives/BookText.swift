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

public struct BookText: BookViewRepresentableType {

  public let text: String
  public var foregroundColor: UIColor = {
    if #available(iOS 13.0, *) {
      return .label
    } else {
      return .darkText
    }
  }()

  public var font: UIFont = .preferredFont(forTextStyle: .body)

  public init(_ text: String) {
    self.text = text
  }

  public func foregroundColor(_ color: UIColor) -> Self {
    modified {
      $0.foregroundColor = color
    }
  }

  public func font(_ font: UIFont) -> Self {
    modified {
      $0.font = font
    }
  }

  public func makeView() -> UIView {
    _View(attributedString: .init(
      string: text,
      attributes: [
        .font : font,
        .foregroundColor : foregroundColor
      ]
      )
    )
  }

  private final class _View: UIView {

    private let label: UILabel

    public init(attributedString: NSAttributedString) {

      self.label = .init()

      super.init(frame: .zero)

      label.numberOfLines = 0

      label.translatesAutoresizingMaskIntoConstraints = false

      addSubview(label)

      NSLayoutConstraint.activate([

        label.topAnchor.constraint(equalTo: topAnchor, constant: 0),
        label.rightAnchor.constraint(equalTo: rightAnchor, constant: -24),
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 24),
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),

      ])

      label.attributedText = attributedString

    }

    public required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

  }

}
