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
import StorybookKit

extension BookTree {

  func findLinks(byQuery string: String) -> [BookNavigationLink] {

    guard string.isEmpty == false else {
      return []
    }

    var results: [BookNavigationLink] = []

    func findLinks(_ tree: BookTree) {
      switch tree {
      case .folder(let v):
        if v.title.contains(string) {
          results.append(v)
        } else {
          findLinks(v.component.asTree())
        }
      case .viewRepresentable:
        break
      case .single(let v?):
        findLinks(v.asTree())
      case .single(.none):
        break
      case .array(let v):
        for i in v {
          findLinks(i)
        }
      }
    }

    findLinks(self)

    return results

  }

  func findLink(by identifier: DeclarationIdentifier) -> BookNavigationLink? {

    func findLink(_ tree: BookTree) -> BookNavigationLink? {
      switch tree {
      case .folder(let v):
        if v.declarationIdentifier == identifier {
          return v
        } else {
          return findLink(v.component.asTree())
        }
      case .viewRepresentable:
        return nil
      case .single(let v?):
        return findLink(v.asTree())
      case .single(.none):
        return nil
      case .array(let v):
        for i in v {
          if let result = findLink(i) {
            return result
          }
        }
        return nil
      }
    }

    return findLink(self)

  }

}
