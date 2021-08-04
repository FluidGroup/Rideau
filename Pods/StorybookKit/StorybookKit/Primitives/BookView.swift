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

public protocol _BookView {

  func asTree() -> BookTree
}

public protocol BookView: _BookView {

  var body: BookView { get }
}

extension BookView {
  public func asTree() -> BookTree {
    return .single(body)
  }
}

extension _BookView {

  public func modified(_ modify: (inout Self) -> Void) -> Self {
    var s = self
    modify(&s)
    return s
  }

}

public struct AnyBookViewRepresentable: BookViewRepresentableType {

  private let _makeView: () -> UIView

  public init<E: BookViewRepresentableType>(_ element: E) {

    self._makeView = element.makeView
  }

  public func asTree() -> BookTree {
    return .viewRepresentable(self)
  }

  public func makeView() -> UIView {
    _makeView()
  }
}
