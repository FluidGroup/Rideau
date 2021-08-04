import UIKit

/**
 A building layout enviroment
 - constraints
 - layout guides
 - tasks apply to view (setting content hugging and compression resistance)
 */
public final class LayoutBuilderContext {

  public weak var targetView: UIView?
  public let name: String?

  public init(
    name: String? = nil,
    targetView: UIView
  ) {
    self.name = name
    self.targetView = targetView
  }

  public private(set) var layoutGuides: [UILayoutGuide] = []
  public private(set) var constraints: [NSLayoutConstraint] = []
  public private(set) var views: [ViewBlock] = []
  public private(set) var viewAppliers: [() -> Void] = []

  func add(constraints: [NSLayoutConstraint]) {
    self.constraints.append(contentsOf: constraints)
  }

  func makeLayoutGuide(identifier: String) -> UILayoutGuide {

    let guide = UILayoutGuide()
    if let name = name {
      guide.identifier = "\(identifier):\(name)"
    } else {
      guide.identifier = identifier
    }

    layoutGuides.append(guide)
    return guide
  }

  func register(viewConstraint: ViewBlock) {
    assert(views.contains(where: { $0.view == viewConstraint.view }) == false)

    views.append(viewConstraint)
    constraints.append(contentsOf: viewConstraint.makeConstraints())
    viewAppliers.append(viewConstraint.makeApplier())
  }

  /// Add including views to the target view.
  public func prepareViewHierarchy() {

    guard let targetView = targetView else {
      return
    }

    views.forEach {
      $0.view.translatesAutoresizingMaskIntoConstraints = false
      targetView.addSubview($0.view)
    }
  }

  /**
   Activate constraints and layout guides.
   */
  public func activate() {

    guard let targetView = targetView else {
      return
    }

    viewAppliers.forEach { $0() }

    layoutGuides.forEach {
      targetView.addLayoutGuide($0)
    }

    NSLayoutConstraint.activate(constraints)

  }

  /**
   Deactivate constraints and layout guides.
   */
  public func deactivate() {

    guard let targetView = targetView else {
      return
    }

    layoutGuides.forEach {
      targetView.removeLayoutGuide($0)
    }

    NSLayoutConstraint.deactivate(constraints)
  }

}

