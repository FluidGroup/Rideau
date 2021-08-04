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

/// A container view that detects subview changes itself size.
/// This view will catch that event and tells StackScrollView to resize.
final class ResizeDetectingView: CodeBasedView, StackCellType {

  private var heightConstraint: NSLayoutConstraint?

  private var wrapper: _Wrapper!

  init(_ body: UIView) {
    super.init(frame: .zero)

    let _wrapper = _Wrapper(body) { [weak self] view in
      guard let self = self, let constraint = self.heightConstraint else { return }

      guard constraint.constant != view.bounds.height else { return }

      constraint.constant = view.bounds.height
      self.layoutIfNeeded()
      self.updateLayout(animated: false)
    }

    self.wrapper = _wrapper

    _wrapper.translatesAutoresizingMaskIntoConstraints = false

    addSubview(_wrapper)

    let top = _wrapper.topAnchor.constraint(equalTo: topAnchor)
    let right = _wrapper.rightAnchor.constraint(equalTo: rightAnchor)
    let left = _wrapper.leftAnchor.constraint(equalTo: leftAnchor)

    NSLayoutConstraint.activate([
      top,
      right,
      left,
    ])

    let size = _wrapper.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

    heightConstraint = heightAnchor.constraint(equalToConstant: size.height)
    heightConstraint!.priority = .defaultHigh
    heightConstraint!.isActive = true
  }

}

fileprivate final class _Wrapper: CodeBasedView, StackCellType {

  private var heightConstraint: NSLayoutConstraint!

  private let onLayoutSubviews: (_Wrapper) -> Void

  init(_ body: UIView, onLayoutSubviews: @escaping (_Wrapper) -> Void) {

    self.onLayoutSubviews = onLayoutSubviews

    super.init(frame: .zero)

    body.translatesAutoresizingMaskIntoConstraints = false

    addSubview(body)

    let top = body.topAnchor.constraint(equalTo: topAnchor)
    let right = body.rightAnchor.constraint(equalTo: rightAnchor)
    let bottom = body.bottomAnchor.constraint(equalTo: bottomAnchor)
    let left = body.leftAnchor.constraint(equalTo: leftAnchor)

    NSLayoutConstraint.activate([
      top,
      right,
      bottom,
      left,
    ])

  }

  override func layoutSubviews() {
    super.layoutSubviews()
    onLayoutSubviews(self)
  }

}
