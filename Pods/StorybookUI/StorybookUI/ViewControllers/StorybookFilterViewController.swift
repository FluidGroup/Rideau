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

public final class StorybookFilterViewController: UIViewController, UISearchBarDelegate {

  public typealias DismissHandler = (StorybookFilterViewController) -> Void

  private let historyManager = HistoryManager.shared
  private let searchBar = UISearchBar()
  private let resultControllerLayoutGuide = UILayoutGuide()

  public let book: Book
  private var currentResultController: UIViewController?

  public init(
    book: Book,
    dismissHandler: DismissHandler?
  ) {
    self.book = book
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  public required init?(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    if #available(iOS 13.0, *) {
      view.backgroundColor = .systemBackground
    } else {
      view.backgroundColor = .white
    }

    searchBar.delegate = self
    searchBar.placeholder = "Type text to search links"
    view.addSubview(searchBar)
    view.addLayoutGuide(resultControllerLayoutGuide)

    searchBar.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      searchBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
      searchBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
    ])

    NSLayoutConstraint.activate([
      resultControllerLayoutGuide.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
      resultControllerLayoutGuide.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
      resultControllerLayoutGuide.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
      resultControllerLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])

  }

  public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

    let query = searchBar.text ?? ""
    let results = book.component.findLinks(byQuery: query)

    currentResultController?.willMove(toParent: nil)
    currentResultController?.view.removeFromSuperview()
    currentResultController?.removeFromParent()

    guard results.isEmpty == false else {
      return
    }

    let resultBook = Book.init(title: "Result") {
      results
    }

    let resultController = ComponentListViewController(
      component: resultBook.component,
      onSelectedLink: { [weak self] link in
        self?.historyManager.updateHistory { (history) in
          history.addLink(link.declarationIdentifier)
        }
      }
    )

    addChild(resultController)
    view.addSubview(resultController.view)

    resultController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      resultController.view.topAnchor.constraint(equalTo: resultControllerLayoutGuide.topAnchor),
      resultController.view.rightAnchor.constraint(equalTo: resultControllerLayoutGuide.rightAnchor),
      resultController.view.leftAnchor.constraint(equalTo: resultControllerLayoutGuide.leftAnchor),
      resultController.view.bottomAnchor.constraint(equalTo: resultControllerLayoutGuide.bottomAnchor),
    ])

  }

}
