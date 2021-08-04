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

import UIKit

import StorybookKit

final class HistoryManager {

  static let shared = HistoryManager()

  private let userDefaults = UserDefaults(suiteName: "jp.eure.storybook")!

  private let decoder = JSONDecoder()
  private let encoder = JSONEncoder()

  var history: History = .init()

  init() {
    loadHistory()
  }

  func updateHistory(_ update: (inout History) -> Void) {
    update(&history)
    do {
      let data = try encoder.encode(history)
      userDefaults.set(data, forKey: "history")
    } catch {
      print("Warning: Failed to encode a history to store UserDefaults")
    }
  }

  private func loadHistory() {
    guard let data = userDefaults.data(forKey: "history") else { return }
    do {
      let instance = try decoder.decode(History.self, from: data)
      self.history = instance
    } catch {
      print("Warning: failed to load a history instance")
    }
  }
}

struct History: Codable {

  private var selectedLinks: [DeclarationIdentifier : Date] = [:]

  func loadSelected() -> [DeclarationIdentifier] {
    selectedLinks.sorted(by: { $0.value > $1.value }).map { $0.key }
  }

  mutating func addLink(_ identifier: DeclarationIdentifier) {
    selectedLinks[identifier] = .init()
  }
}

public final class StorybookViewController : UISplitViewController {

  private let historyManager = HistoryManager.shared
  
  public typealias DismissHandler = (StorybookViewController) -> Void
  
  private var mainViewController: UINavigationController!
  
  private let secondaryViewController = UINavigationController()
  
  private let dismissHandler: DismissHandler?
  
  public init(book: Book, dismissHandler: DismissHandler?) {

    self.dismissHandler = dismissHandler

    super.init(nibName: nil, bundle: nil)

    let history = historyManager.history.loadSelected().compactMap {
      book.component.findLink(by: $0)
    }
    .prefix(8)

    let root = BookGroup {
      BookPage(title: book.title) {
        if !history.isEmpty {
          BookSection(title: "History") {
            BookTree.array(history.map { $0.asTree() })
          }
        }
        BookSection(title: "All") {
          BookNavigationLink(title: "View all") {
            flatten(book.component)
          }
        }
        BookSection(title: "Contents") {
          book.component
        }
      }

    }

    let menuController = ComponentListViewController(
      component: root.asTree(),
      onSelectedLink: { [weak self] link in
        self?.historyManager.updateHistory { (history) in
          history.addLink(link.declarationIdentifier)
        }
    })

    self.mainViewController = UINavigationController(rootViewController: menuController)

    if dismissHandler != nil {
      let dismissButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDismissButton))
      menuController.navigationItem.leftBarButtonItem = dismissButton
    }

    viewControllers = [
      mainViewController,
      secondaryViewController,
    ]

  }
    
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    delegate = self
    preferredDisplayMode = .allVisible
    
  }
  
  public override func showDetailViewController(_ vc: UIViewController, sender: Any?) {
    
    if isCollapsed {
      super.showDetailViewController(vc, sender: sender)
    } else {
      super.showDetailViewController(UINavigationController(rootViewController: vc), sender: sender)
    }
    
  }
  
  @objc private func didTapDismissButton() {
    dismissHandler?(self)
  }
  
  public override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    
    if #available(iOS 13.0, *) {
      if motion == .motionShake {
        didShake()
      }
    }
  }
  
  @available(iOS 13.0, *)
  private func didShake() {

    let currentStyle: String = {      
      switch overrideUserInterfaceStyle {
      case .light: return "Light"
      case .dark: return "Dark"
      case .unspecified: break
      @unknown default: break
      }
      
      switch traitCollection.userInterfaceStyle {
      case .light: return "System (Light)"
      case .dark: return "System (Dark)"
      case .unspecified: return "System (Unspecified)"
      @unknown default: return "System (Unspecified)"
      }
    }()

    let c = UIAlertController(
      title: "User Interface Style",
      message: "current: \(currentStyle)",
      preferredStyle: .actionSheet
    )
    
    c.addAction(.init(
      title: "System",
      style: .default,
      handler: { _ in self.overrideUserInterfaceStyle = .unspecified }
      ))

    c.addAction(.init(
      title: "Light",
      style: .default,
      handler: { _ in self.overrideUserInterfaceStyle = .light }
      ))

    c.addAction(.init(
      title: "Dark",
      style: .default,
      handler: { _ in self.overrideUserInterfaceStyle = .dark }
      ))

    c.addAction(.init(title: "Cancel", style: .cancel))
    present(c, animated: true)
  }
}

extension StorybookViewController : UISplitViewControllerDelegate {
  
  public func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
  }
  
  public func splitViewController(_ splitViewController: UISplitViewController, show vc: UIViewController, sender: Any?) -> Bool {
    return true
  }
  
  public func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
    return false
  }
  
  public func splitViewControllerSupportedInterfaceOrientations(_ splitViewController: UISplitViewController) -> UIInterfaceOrientationMask {
    return .all
  }
  
  public func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
    return secondaryViewController
  }
  
  public func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
    return true
  }
}

fileprivate func flatten(_ tree: BookTree) -> BookTree {

  func _flatten(buffer: inout [BookTree], tree: BookTree) {
    switch tree {
    case .folder(let v):
      _flatten(buffer: &buffer, tree: v.component)
    case .viewRepresentable:
      buffer.append(tree)
    case .single(let v?):
      _flatten(buffer: &buffer, tree: v.asTree())
    case .single(.none):
      break
    case .array(let v):
      v.forEach {
        _flatten(buffer: &buffer, tree: $0)
      }
    }
  }

  var buffer = [BookTree]()
  _flatten(buffer: &buffer, tree: tree)

  return .array(buffer)
}
