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

final class ComponentListViewController: StackScrollViewController {

  var onSelectedLink: (BookNavigationLink) -> Void = { _ in }

  init(component: BookTree, onSelectedLink: @escaping (BookNavigationLink) -> Void) {

    super.init()

    func makeCells(buffer: inout [UIView], component: BookTree) {

      switch component {
      case .folder(let v):
        buffer.append(
          FolderCell(title: v.title, didTap: { [weak self] in

            onSelectedLink(v)

            let nextController = ComponentListViewController(
              component: v.component,
              onSelectedLink: onSelectedLink
            )
            nextController.title = v.title
            self?.showDetailViewController(nextController, sender: self)
          })
        )
      case .single(let v):
        if let v = v {
          makeCells(buffer: &buffer, component: v.asTree())
        }
      case .viewRepresentable(let v):
        buffer.append(
          v.makeView()
        )
      case .array(let v):
        v.forEach {
          makeCells(buffer: &buffer, component: $0)
        }
      }

    }

    var buffer = [UIView]()
    makeCells(buffer: &buffer, component: component)

    setViews(buffer)

  }

}


