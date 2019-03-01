//
// Rideau
//
// Copyright © 2019 Hiroshi Kimura
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
import CoreGraphics.CGGeometry

struct Progress {

  var fractionCompleted: CGFloat

  init(_ fractionCompleted: CGFloat) {
    self.fractionCompleted = fractionCompleted
  }
}

struct CalcBox<T> {

  var value: T

  init(_ value: T) {
    self.value = value
  }
}

extension CalcBox where T == CGFloat {

  func clip(min: CGFloat, max: CGFloat) -> CalcBox<CGFloat> {
    return .init(Swift.max(Swift.min(value, max), min))
  }

  func progress(start: CGFloat, end: CGFloat) -> CalcBox<Progress> {
    return .init(Progress.init((value - start) / (end - start)))
  }
}

extension CalcBox where T == Progress {

  func reverse() -> CalcBox<Progress> {
    return .init(Progress(1 - value.fractionCompleted))
  }

  func transition(start: CGFloat, end: CGFloat) -> CalcBox<CGFloat> {
    return .init(((end - start) * value.fractionCompleted) + start)
  }

  func clip(min: CGFloat, max: CGFloat) -> CalcBox<Progress> {
    return .init(Progress(Swift.max(Swift.min(value.fractionCompleted, max), min)))
  }
}

extension CalcBox where T == CGPoint {

  func vector() -> CalcBox<CGVector> {
    return .init(CGVector(dx: value.x, dy: value.y))
  }

  func distance(from: CGPoint) -> CalcBox<CGFloat> {
    return .init(sqrt(pow(value.x - from.x, 2) + pow(value.y - from.y, 2)))
  }

  func distance(to: CGPoint) -> CalcBox<CGFloat> {
    return .init(sqrt(pow(to.x - value.x, 2) + pow(to.y - value.y, 2)))
  }
}

extension CalcBox where T == CGVector {
  func magnitude() -> CGFloat {
    return sqrt(pow(value.dx, 2) + pow(value.dy, 2))
  }
}

func _getActualContentInset(from scrollView: UIScrollView) -> UIEdgeInsets {
  var insets = scrollView.contentInset
  if #available(iOS 11, *) {
    let adjustedInsets = scrollView.adjustedContentInset
    insets.top += adjustedInsets.top
    insets.left += adjustedInsets.left
    insets.bottom += adjustedInsets.bottom
    insets.right += adjustedInsets.right
  }
  return insets
}
