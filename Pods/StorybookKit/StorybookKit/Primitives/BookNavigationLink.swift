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

public struct DeclarationIdentifier: Hashable, Codable {

  public let file: String
  public let line: UInt
  public let column: UInt
  public let typeName: String
}

/// A component that displays a disclosure view.
public struct BookNavigationLink: BookView {

  public let title: String
  public let component: BookTree
  public let declarationIdentifier: DeclarationIdentifier

  public init(
    title: String,
    _ file: StaticString = #file,
    _ line: UInt = #line,
    _ column: UInt = #column,
    @ComponentBuilder closure: () -> _BookView
  ) {
    self.title = title
    self.component = closure().asTree()
    self.declarationIdentifier = .init(
      file: file.description,
      line: line,
      column: column,
      typeName: _typeName(type(of: self))
    )
  }

  public var body: BookView {
    self
  }

  public func asTree() -> BookTree {
    .folder(self)
  }
}

