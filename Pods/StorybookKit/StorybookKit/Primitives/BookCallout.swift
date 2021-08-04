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

public struct BookCallout: BookViewRepresentableType {

  public static func info(text: String) -> Self {
    return .init(symbol: "☝️", text: text)
  }

  public static func warning(text: String) -> Self {
    return .init(symbol: "⚠️", text: text)
  }

  public static func danger(text: String) -> Self {
    return .init(symbol: "🚨", text: text)
  }

  public static func success(text: String) -> Self {
    return .init(symbol: "✅", text: text)
  }

  public let symbol: String?
  public let text: String
  public var foregroundColor: UIColor = {
    if #available(iOS 13.0, *) {
      return .label
    } else {
      return .darkText
    }
  }()

  public var font: UIFont = .preferredFont(forTextStyle: .body)

  public init(
    symbol: String? = nil,
    text: String
  ) {
    self.symbol = symbol
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
    _View(
      symbol: symbol.map {
        .init(
          string: $0,
          attributes: [
            .font: font,
            .foregroundColor: foregroundColor,
          ]
        )
      },
      attributedString: .init(
        string: text,
        attributes: [
          .font: font,
          .foregroundColor: foregroundColor,
        ]
      )
    )
  }

  private final class _View: UIView {

    private let symbolLabel: UILabel?
    private let label: UILabel
    private let backgroundView = UIView()

    public init(
      symbol: NSAttributedString?,
      attributedString: NSAttributedString
    ) {

      self.label = .init()

      if symbol != nil {
        symbolLabel = .init()
      } else {
        symbolLabel = nil
      }

      super.init(frame: .zero)

      label.numberOfLines = 0

      label.translatesAutoresizingMaskIntoConstraints = false
      backgroundView.translatesAutoresizingMaskIntoConstraints = false

      addSubview(backgroundView)
      backgroundView.addSubview(label)

      if let symbolLabel = symbolLabel {

        symbolLabel.setContentHuggingPriority(.required, for: .horizontal)
        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        symbolLabel.attributedText = symbol
        backgroundView.addSubview(symbolLabel)

        NSLayoutConstraint.activate([

          backgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
          backgroundView.rightAnchor.constraint(equalTo: rightAnchor, constant: -22),
          backgroundView.leftAnchor.constraint(equalTo: leftAnchor, constant: 22),
          backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

          symbolLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 12),
          symbolLabel.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 12),
          symbolLabel.bottomAnchor.constraint(
            lessThanOrEqualTo: backgroundView.bottomAnchor,
            constant: -12
          ),

          label.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 12),
          label.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -12),
          label.leftAnchor.constraint(equalTo: symbolLabel.rightAnchor, constant: 8),
          label.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -12),

        ])
      } else {
        NSLayoutConstraint.activate([

          backgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
          backgroundView.rightAnchor.constraint(equalTo: rightAnchor, constant: -22),
          backgroundView.leftAnchor.constraint(equalTo: leftAnchor, constant: 22),
          backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),

          label.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 12),
          label.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -12),
          label.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 12),
          label.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -12),

        ])
      }

      backgroundView.backgroundColor = UIColor(white: 0.8, alpha: 0.3)
      backgroundView.layer.cornerRadius = 8
      if #available(iOS 13.0, *) {
        backgroundView.layer.cornerCurve = .continuous
      } else {
        // Fallback on earlier versions
      }

      label.attributedText = attributedString

    }

    public required init?(
      coder: NSCoder
    ) {
      fatalError("init(coder:) has not been implemented")
    }

  }

}
