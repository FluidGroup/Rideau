import UIKit

@discardableResult
public func mondrianBatchLayout(
  @MondrianArrayBuilder<LayoutDescriptor> _ closure: () -> [LayoutDescriptor]
) -> ConstraintGroup {

  let descriptors = closure()

  let group = ConstraintGroup(constraints: [])

  descriptors.forEach {
    let g = $0.activate()
    group.append(g)
  }

  return group

}

public final class ConstraintGroup {

  public private(set) var constraints: [NSLayoutConstraint]

  public init(
    constraints: [NSLayoutConstraint]
  ) {
    self.constraints = constraints
  }

  public func append(_ constraint: NSLayoutConstraint) {
    self.constraints.append(constraint)
  }

  public func append(_ otherGroup: ConstraintGroup) {
    self.constraints.append(contentsOf: otherGroup.constraints)
  }

  public func activate() {

    NSLayoutConstraint.activate(constraints)
  }

  public func deactivate() {

    NSLayoutConstraint.deactivate(constraints)
  }

}

public enum EdgeAttaching {}
public enum CenterPositioning {}

public struct LayoutDescriptorElement<Trait> {

  let usesSuperview: Bool
  let layoutElement: _LayoutElement?

  var anchorXAxis: _LayoutElement.XAxisAnchor?
  var anchorYAxis: _LayoutElement.YAxisAnchor?

  public static func to(_ element: _LayoutElement) -> LayoutDescriptorElement {
    return .init(usesSuperview: false, layoutElement: element)
  }

  public static func to(_ view: UIView) -> LayoutDescriptorElement {
    return .init(usesSuperview: false, layoutElement: .init(view: view))
  }

  public static func to(_ layoutGuide: UILayoutGuide) -> LayoutDescriptorElement {
    return .init(usesSuperview: false, layoutElement: .init(layoutGuide: layoutGuide))
  }

  public static var toSuperview: LayoutDescriptorElement {
    return .init(usesSuperview: true, layoutElement: nil)
  }

}

extension LayoutDescriptorElement where Trait == CenterPositioning {

  public func positioned(x: _LayoutElement.XAxisAnchor, y: _LayoutElement.YAxisAnchor) -> Self {
    modified(self) {
      $0.anchorXAxis = x
      $0.anchorYAxis = y
    }
  }

}

extension LayoutDescriptorElement where Trait == _LayoutElement.XAxisAnchor {
  public var left: Self {
    modified(self) {
      $0.anchorXAxis = .left
    }
  }

  public var right: Self {
    modified(self) {
      $0.anchorXAxis = .right
    }
  }

  public var centerX: Self {
    modified(self) {
      $0.anchorXAxis = .centerX
    }
  }

  public var leading: Self {
    modified(self) {
      $0.anchorXAxis = .leading
    }
  }

  public var trailing: Self {
    modified(self) {
      $0.anchorXAxis = .trailing
    }
  }
}

extension LayoutDescriptorElement where Trait == _LayoutElement.YAxisAnchor {
  public var top: Self {
    modified(self) {
      $0.anchorYAxis = .top
    }
  }

  public var bottom: Self {
    modified(self) {
      $0.anchorYAxis = .bottom
    }
  }

  public var centerY: Self {
    modified(self) {
      $0.anchorYAxis = .centerY
    }
  }
}

/// A representation of how sets the constraints from the target element (UIView or UILayoutGuide).
public struct LayoutDescriptor: _DimensionConstraintType {

  public struct ConstraintValue: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {

    public typealias IntegerLiteralType = Int
    public typealias FloatLiteralType = Double

    public enum Relation {
      /// greater than or equal
      case min
      /// equal
      case exact
      /// less than or equal
      case max
    }

    public var relation: Relation
    public var constant: CGFloat
    public var priority: UILayoutPriority

    public init(integerLiteral value: Int) {
      self.init(relation: .exact, constant: CGFloat(value), priority: .required)
    }

    public init(floatLiteral value: FloatLiteralType) {
      self.init(relation: .exact, constant: CGFloat(value), priority: .required)
    }

    public init(
      relation: Relation,
      constant: CGFloat,
      priority: UILayoutPriority
    ) {
      self.relation = relation
      self.constant = constant
      self.priority = priority
    }

    /// greater than or equal
    public static func min(_ value: CGFloat, _ priority: UILayoutPriority = .required) -> Self {
      return .init(relation: .min, constant: value, priority: priority)
    }

    /// equal
    public static func exact(_ value: CGFloat, _ priority: UILayoutPriority = .required) -> Self
    {
      return .init(relation: .exact, constant: value, priority: priority)
    }

    @available(*, deprecated, renamed: "exact")
    public static func constant(_ value: CGFloat, _ priority: UILayoutPriority = .required) -> Self
    {
      return .init(relation: .exact, constant: value, priority: priority)
    }

    /// less than or equal
    public static func max(_ value: CGFloat, _ priority: UILayoutPriority = .required) -> Self {
      return .init(relation: .max, constant: value, priority: priority)
    }
  }

  private let target: _LayoutElement

  /// Creates an instance from `UIView`.
  public init(
    view: UIView
  ) {
    self.target = .init(view: view)
  }

  /// Creates an instance from `UILayoutGuide`.
  public init(
    layoutGuide: UILayoutGuide
  ) {
    self.target = .init(layoutGuide: layoutGuide)
  }

  public var dimensionConstraints: DimensionDescriptor = .init()

  @inline(__always)
  private func takeParentLayoutElementWithAssertion() -> _LayoutElement? {
    assert(
      target.owningView != nil,
      "\(target.view ?? target.layoutGuide as Any) must have parent view."
    )
    return target.owningView.map { .init(view: $0) }
  }

  @inline(__always)
  private func takeLayoutElement<T>(_ element: LayoutDescriptorElement<T>) -> _LayoutElement? {

    guard element.usesSuperview == false else {
      return takeParentLayoutElementWithAssertion()
    }

    return element.layoutElement
  }

  private var proposedConstraints: [NSLayoutConstraint] = []

  @inline(__always)
  private func _modify(_ modifier: (inout Self) -> Void) -> Self {
    var new = self
    modifier(&new)
    return new
  }

  @inline(__always)
  @discardableResult
  private mutating func makeConstraint<T>(
    _ element: LayoutDescriptorElement<T>,
    _ closure: (_LayoutElement, _LayoutElement) -> NSLayoutConstraint
  ) -> NSLayoutConstraint? {

    guard let secondItem = takeLayoutElement(element) else {
      return nil
    }

    let constraint = closure(target, secondItem)
    proposedConstraints.append(constraint)
    return constraint
  }

  @inline(__always)
  @discardableResult
  private mutating func makeConstraints<T>(
    _ element: LayoutDescriptorElement<T>,
    _ closure: (_LayoutElement, _LayoutElement) -> [NSLayoutConstraint]
  ) -> [NSLayoutConstraint]? {

    guard let secondItem = takeLayoutElement(element) else {
      return nil
    }

    let constraints = closure(target, secondItem)
    self.proposedConstraints.append(contentsOf: constraints)
    return constraints
  }

  // MARK: - X axis

  @inline(__always)
  private func _anchor<T>(
    from: _LayoutElement.XAxisAnchor,
    element: LayoutDescriptorElement<T>,
    defaultAnchor anchor: _LayoutElement.XAxisAnchor,
    value: ConstraintValue
  ) -> Self {
    return _modify {
      $0.makeConstraint(element) {
        $0.anchor(from).constraint(value: value, to: $1.anchor(element.anchorXAxis ?? anchor))
      }
    }
  }

  @inline(__always)
  private func _anchor<T>(
    from: _LayoutElement.YAxisAnchor,
    element: LayoutDescriptorElement<T>,
    defaultAnchor anchor: _LayoutElement.YAxisAnchor,
    value: ConstraintValue
  ) -> Self {
    return _modify {
      $0.makeConstraint(element) {
        $0.anchor(from).constraint(value: value, to: $1.anchor(element.anchorYAxis ?? anchor))
      }
    }
  }

  /// Describes a single constraint
  ///
  /// As default, attaches to `leading` of the element
  public func leading(
    _ element: LayoutDescriptorElement<_LayoutElement.XAxisAnchor>,
    _ value: ConstraintValue = .exact(0)
  ) -> Self {
    _anchor(from: .leading, element: element, defaultAnchor: .leading, value: value)
  }

  /// Describes a single constraint
  ///
  /// As default, attaches to `trailing` of the element
  public func trailing(
    _ element: LayoutDescriptorElement<_LayoutElement.XAxisAnchor>,
    _ value: ConstraintValue = .exact(0)
  ) -> Self {
    _anchor(from: .trailing, element: element, defaultAnchor: .trailing, value: value)
  }

  /// Describes a single constraint
  ///
  /// As default, attaches to `left` of the element
  public func left(
    _ element: LayoutDescriptorElement<_LayoutElement.XAxisAnchor>,
    _ value: ConstraintValue = .exact(0)
  ) -> Self {
    _anchor(from: .left, element: element, defaultAnchor: .left, value: value)
  }

  /// Describes a single constraint
  ///
  /// As default, attaches to `right` of the element
  public func right(
    _ element: LayoutDescriptorElement<_LayoutElement.XAxisAnchor>,
    _ value: ConstraintValue = .exact(0)
  ) -> Self {
    _anchor(from: .right, element: element, defaultAnchor: .right, value: value)
  }

  /// Describes a single constraint
  ///
  /// As default, attaches to `centerX` of the element
  public func centerX(
    _ element: LayoutDescriptorElement<_LayoutElement.XAxisAnchor>,
    _ value: ConstraintValue = .exact(0)
  ) -> Self {
    _anchor(from: .centerX, element: element, defaultAnchor: .centerX, value: value)
  }

  // MARK: - Y axis

  /// Describes a single constraint
  ///
  /// As default, attaches to `top` of the element
  public func top(
    _ element: LayoutDescriptorElement<_LayoutElement.YAxisAnchor>,
    _ value: ConstraintValue = .exact(0)
  ) -> Self {
    _anchor(from: .top, element: element, defaultAnchor: .top, value: value)
  }

  /// Describes a single constraint
  ///
  /// As default, attaches to `bottom` of the element
  public func bottom(
    _ element: LayoutDescriptorElement<_LayoutElement.YAxisAnchor>,
    _ value: ConstraintValue = .exact(0)
  ) -> Self {
    _anchor(from: .bottom, element: element, defaultAnchor: .bottom, value: value)
  }

  /// Describes a single constraint
  ///
  /// As default, attaches to `centerY` of the element
  public func centerY(
    _ element: LayoutDescriptorElement<_LayoutElement.YAxisAnchor>,
    _ value: ConstraintValue = .exact(0)
  ) -> Self {
    _anchor(from: .centerY, element: element, defaultAnchor: .centerY, value: value)
  }

  // MARK: - Sugars

  /// Describes multiple constraints
  public func center(
    _ element: LayoutDescriptorElement<CenterPositioning>,
    _ value: ConstraintValue = .exact(0)
  ) -> Self {
    return _modify {
      $0.makeConstraints(
        element,
        {
          [
            $0.anchor(.centerY).constraint(
              value: value,
              to: $1.anchor(element.anchorYAxis ?? .centerY)
            ),
            $0.anchor(.centerX).constraint(
              value: value,
              to: $1.anchor(element.anchorXAxis ?? .centerX)
            ),
          ]
        }
      )
    }
  }

  /// Describes multiple constraints
  public func edges(
    _ element: LayoutDescriptorElement<EdgeAttaching>,
    _ value: ConstraintValue = .exact(0)
  ) -> Self {
    return _modify {
      $0.makeConstraints(
        element,
        {
          [
            $0.anchor(.top).constraint(value: value, to: $1.topAnchor),
            $1.anchor(.bottom).constraint(value: value, to: $0.bottomAnchor),
            $0.anchor(.left).constraint(value: value, to: $1.leftAnchor),
            $1.anchor(.right).constraint(value: value, to: $0.rightAnchor),
          ]
        }
      )
    }
  }

  /// Describes multiple constraints
  public func horizontal(
    _ element: LayoutDescriptorElement<EdgeAttaching>,
    _ value: ConstraintValue = .exact(0)
  ) -> Self {
    return _modify {
      $0.makeConstraints(
        element,
        {
          [
            $0.anchor(.left).constraint(value: value, to: $1.leftAnchor),
            $1.anchor(.right).constraint(value: value, to: $0.rightAnchor),
          ]
        }
      )
    }
  }

  /// Describes multiple constraints
  public func vertical(
    _ element: LayoutDescriptorElement<EdgeAttaching>,
    _ value: ConstraintValue = .exact(0)
  ) -> Self {
    return _modify {
      $0.makeConstraints(
        element,
        {
          [
            $0.anchor(.top).constraint(value: value, to: $1.topAnchor),
            $1.anchor(.bottom).constraint(value: value, to: $0.bottomAnchor),
          ]
        }
      )
    }
  }

  /**
   Activates layout constraints
   */
  @discardableResult
  public func activate() -> ConstraintGroup {

    target.view?.translatesAutoresizingMaskIntoConstraints = false
    let group = makeConstraintGroup()
    group.activate()
    return group

  }

  public func makeConstraintGroup() -> ConstraintGroup {
    return ConstraintGroup(constraints: makeConstraints())
  }

  public func makeConstraints() -> [NSLayoutConstraint] {
    let _dimensionConstraints = dimensionConstraints.makeConstraints(for: target)
    return proposedConstraints + _dimensionConstraints
  }

}

extension NSLayoutXAxisAnchor {

  fileprivate func constraint(
    value: LayoutDescriptor.ConstraintValue,
    to anchor: NSLayoutXAxisAnchor
  ) -> NSLayoutConstraint {

    switch value.relation {
    case .min:
      return constraint(greaterThanOrEqualTo: anchor, constant: value.constant).setPriority(
        value.priority
      )
    case .exact:
      return constraint(equalTo: anchor, constant: value.constant).setPriority(value.priority)
    case .max:
      return constraint(lessThanOrEqualTo: anchor, constant: value.constant).setPriority(
        value.priority
      )
    }

  }
}

extension NSLayoutYAxisAnchor {

  fileprivate func constraint(
    value: LayoutDescriptor.ConstraintValue,
    to anchor: NSLayoutYAxisAnchor
  ) -> NSLayoutConstraint {

    switch value.relation {
    case .min:
      return constraint(greaterThanOrEqualTo: anchor, constant: value.constant).setPriority(
        value.priority
      )
    case .exact:
      return constraint(equalTo: anchor, constant: value.constant).setPriority(value.priority)
    case .max:
      return constraint(lessThanOrEqualTo: anchor, constant: value.constant).setPriority(
        value.priority
      )
    }

  }
}

extension MondrianNamespace where Base: UIView {

  /**
   Entry point to describe layout constraints
   Activates by calling `activate()` or using `mondrianBatchLayout`

   ```swift
   view.mondrian.layout
     .top(.toSuperview)
     .left(.toSuperview)
     .right(.to(box2), .left)
     .bottom(.to(box2), .bottom)
     .activate()
   ```
   */
  public var layout: LayoutDescriptor {
    .init(view: base)
  }

}

extension MondrianNamespace where Base: UILayoutGuide {

  /**
   Entry point to describe layout constraints
   Activates by calling `activate()` or using `mondrianBatchLayout`

   ```swift
   view.mondrian.layout
     .top(.toSuperview)
     .left(.toSuperview)
     .right(.to(box2), .left)
     .bottom(.to(box2), .bottom)
     .activate()
   ```
   */
  public var layout: LayoutDescriptor {
    .init(layoutGuide: base)
  }

}
