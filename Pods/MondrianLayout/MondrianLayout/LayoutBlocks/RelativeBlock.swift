import UIKit

/// [MondrianLayout]
/// A descriptor that lays out a single content and positions within the parent according to vertical and horizontal positional length.
public struct RelativeBlock: _LayoutBlockType, _LayoutBlockNodeConvertible {

  public struct ConstrainedValue: Equatable, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public var min: CGFloat?
    public var exact: CGFloat?
    public var max: CGFloat?

    var isEmpty: Bool {
      return min == nil && exact == nil && max == nil
    }

    var isExactOnly: Bool {
      return exact != nil && min == nil && max == nil
    }

    public init(
      integerLiteral value: Int
    ) {
      self.init(min: nil, exact: CGFloat(value), max: nil)
    }

    public init(
      floatLiteral value: Double
    ) {
      self.init(min: nil, exact: CGFloat(value), max: nil)
    }

    public init(
      min: CGFloat? = nil,
      exact: CGFloat? = nil,
      max: CGFloat? = nil
    ) {
      self.min = min
      self.exact = exact
      self.max = max
    }

    public mutating func accumulate(keyPath: WritableKeyPath<Self, CGFloat?>, _ other: CGFloat?) {
      self[keyPath: keyPath] =
        other.map { (self[keyPath: keyPath] ?? 0) + $0 } ?? self[keyPath: keyPath]
    }

    public mutating func accumulate(_ other: Self) {
      accumulate(keyPath: \.min, other.min)
      accumulate(keyPath: \.exact, other.exact)
      accumulate(keyPath: \.max, other.max)
    }

    /// greater than or equal
    public static func min(_ value: CGFloat) -> Self {
      return .init(min: value, exact: nil, max: nil)
    }

    /// equal
    public static func exact(_ value: CGFloat) -> Self {
      return .init(min: nil, exact: value, max: nil)
    }

    /// less than or equal
    public static func max(_ value: CGFloat) -> Self {
      return .init(min: nil, exact: nil, max: value)
    }
  }

  public var name: String = "Relative"

  public var _layoutBlockNode: _LayoutBlockNode {
    return .relative(self)
  }

  public let content: _LayoutBlockNode

  var top: ConstrainedValue
  var bottom: ConstrainedValue
  var trailing: ConstrainedValue
  var leading: ConstrainedValue

  init(
    top: ConstrainedValue? = nil,
    leading: ConstrainedValue? = nil,
    bottom: ConstrainedValue? = nil,
    trailing: ConstrainedValue? = nil,
    content: () -> _LayoutBlockNode
  ) {

    self.top = top ?? .init()
    self.leading = leading ?? .init()
    self.bottom = bottom ?? .init()
    self.trailing = trailing ?? .init()
    self.content = content()
  }

  public func setupConstraints(parent: _LayoutElement, in context: LayoutBuilderContext) {

    func perform(current: _LayoutElement) {

      var proposedConstraints: [NSLayoutConstraint] = []

      // setting up constraints according to values

      proposedConstraints +=
        ([
          top.exact.map {
            current.topAnchor.constraint(equalTo: parent.topAnchor, constant: $0)
          },
          trailing.exact.map {
            current.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -$0)
          },
          leading.exact.map {
            current.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: $0)
          },
          bottom.exact.map {
            current.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -$0)
          },

          top.min.map {
            current.topAnchor.constraint(greaterThanOrEqualTo: parent.topAnchor, constant: $0)
          },
          trailing.min.map {
            current.trailingAnchor.constraint(lessThanOrEqualTo: parent.trailingAnchor, constant: -$0)
          },
          leading.min.map {
            current.leadingAnchor.constraint(greaterThanOrEqualTo: parent.leadingAnchor, constant: $0)
          },
          bottom.min.map {
            current.bottomAnchor.constraint(lessThanOrEqualTo: parent.bottomAnchor, constant: -$0)
          },

          top.max.map {
            current.topAnchor.constraint(lessThanOrEqualTo: parent.topAnchor, constant: $0)
          },
          trailing.max.map {
            current.trailingAnchor.constraint(greaterThanOrEqualTo: parent.trailingAnchor, constant: -$0)
          },
          leading.max.map {
            current.leadingAnchor.constraint(lessThanOrEqualTo: parent.leadingAnchor, constant: $0)
          },
          bottom.max.map {
            current.bottomAnchor.constraint(greaterThanOrEqualTo: parent.bottomAnchor, constant: -$0)
          },

        ] as [NSLayoutConstraint?]).compactMap { $0 }

      constraintsToFitInsideContainer: do {

        /**
         If a edge does not have minimum or exact value, the element might be overflowed.
         */

        if bottom.min == nil, bottom.exact == nil {
          proposedConstraints.append(
            current.bottomAnchor.constraint(lessThanOrEqualTo: parent.bottomAnchor)
          )
        }

        if top.min == nil, top.exact == nil {
          proposedConstraints.append(
            current.topAnchor.constraint(greaterThanOrEqualTo: parent.topAnchor)
          )
        }

        if leading.min == nil, leading.exact == nil {
          proposedConstraints.append(
            current.trailingAnchor.constraint(lessThanOrEqualTo: parent.trailingAnchor)
          )
        }

        if trailing.min == nil, trailing.exact == nil {
          proposedConstraints.append(
            current.trailingAnchor.constraint(lessThanOrEqualTo: parent.trailingAnchor)
          )
        }

      }

      constraintsToPositionCenter: do {

        /**
         Vertically or horizontally, if there are no specifiers, that causes an ambiguous layout.
         As a default behavior, in that case, adds centering layout constraints.
         */

        vertical: do {

          let edges = [bottom, top]

          if edges.allSatisfy({ $0.exact == nil }) {
            proposedConstraints.append(
              current.centerYAnchor.constraint(equalTo: parent.centerYAnchor).setPriority(
                .defaultHigh
              )
            )
          }
        }

        horizontal: do {

          let edges = [leading, trailing]

          if edges.allSatisfy({ $0.exact == nil }) {
            proposedConstraints.append(
              current.centerXAnchor.constraint(equalTo: parent.centerXAnchor).setPriority(
                .defaultHigh
              )
            )
          }
        }

      }

      proposedConstraints.forEach {
        $0.setInternalIdentifier(name)
      }

      context.add(constraints: proposedConstraints)

    }

    switch content {
    case .view(let viewConstarint):

      context.register(viewConstraint: viewConstarint)

      perform(current: .init(view: viewConstarint.view))

    case .vStack(let c as _LayoutBlockType),
      .hStack(let c as _LayoutBlockType),
      .zStack(let c as _LayoutBlockType),
      .background(let c as _LayoutBlockType),
      .relative(let c as _LayoutBlockType),
      .overlay(let c as _LayoutBlockType):

      let newLayoutGuide = context.makeLayoutGuide(identifier: "RelativeBlock.\(c.name)")
      c.setupConstraints(parent: .init(layoutGuide: newLayoutGuide), in: context)
      perform(current: .init(layoutGuide: newLayoutGuide))

    }

  }

}

extension _LayoutBlockNodeConvertible {

  /**
   `.relative` modifier describes that the content attaches to specified edges with padding.
   Not specified edges do not have constraints to the edge. so the sizing depends on intrinsic content size.

   You might use this modifier to pin to edge as an overlay content.

   ```swift
   ZStackBlock {
     VStackBlock {
       ...
     }
     .relative(bottom: 8, right: 8)
   }
   ```
   */
  private func relative(
    top: RelativeBlock.ConstrainedValue,
    leading: RelativeBlock.ConstrainedValue,
    bottom: RelativeBlock.ConstrainedValue,
    trailing: RelativeBlock.ConstrainedValue
  ) -> RelativeBlock {

    if case .relative(let relativeBlock) = self._layoutBlockNode {
      var new = relativeBlock

      new.top.accumulate(top)
      new.leading.accumulate(leading)
      new.trailing.accumulate(trailing)
      new.bottom.accumulate(bottom)

      return new
    } else {
      return .init(top: top, leading: leading, bottom: bottom, trailing: trailing) {
        self._layoutBlockNode
      }
    }
  }

  /**
   `.relative` modifier describes that the content attaches to specified edges with padding.
   Not specified edges do not have constraints to the edge. so the sizing depends on intrinsic content size.

   You might use this modifier to pin to edge as an overlay content.
   */
  public func relative(_ value: RelativeBlock.ConstrainedValue) -> RelativeBlock {
    return relative(top: value, leading: value, bottom: value, trailing: value)
  }

  /**
   `.relative` modifier describes that the content attaches to specified edges with padding.
   Not specified edges do not have constraints to the edge. so the sizing depends on intrinsic content size.

   You might use this modifier to pin to edge as an overlay content.
   */
  @_disfavoredOverload
  public func relative(_ value: CGFloat) -> RelativeBlock {
    return relative(.exact(value))
  }

  /**
   `.relative` modifier describes that the content attaches to specified edges with padding.
   Not specified edges do not have constraints to the edge. so the sizing depends on intrinsic content size.

   You might use this modifier to pin to edge as an overlay content.
   */
  public func relative(_ edgeInsets: UIEdgeInsets) -> RelativeBlock {
    return relative(
      top: .init(floatLiteral: Double(edgeInsets.top)),
      leading: .init(floatLiteral: Double(edgeInsets.left)),
      bottom: .init(floatLiteral: Double(edgeInsets.bottom)),
      trailing: .init(floatLiteral: Double(edgeInsets.right))
    )
  }

  /**
   `.relative` modifier describes that the content attaches to specified edges with padding.
   Not specified edges do not have constraints to the edge. so the sizing depends on intrinsic content size.

   You might use this modifier to pin to edge as an overlay content.

   Ambiguous position would be fixed by centering.
   For example:
   - lays out centered vertically if you only set horizontal values vice versa.
   - also only setting minimum value in the axis.

   */
  public func relative(_ edges: Edge.Set, _ value: RelativeBlock.ConstrainedValue) -> RelativeBlock {

    return relative(
      top: edges.contains(.top) ? value : .init(),
      leading: edges.contains(.leading) ? value : .init(),
      bottom: edges.contains(.bottom) ? value : .init(),
      trailing: edges.contains(.trailing) ? value : .init()
    )

  }

  @_disfavoredOverload
  public func relative(_ edges: Edge.Set, _ value: CGFloat) -> RelativeBlock {
    return relative(edges, .exact(value))
  }

  /**
   .padding modifier is similar with .relative but something different.
   Different with that, Not specified edges pin to edge with 0 padding.

   Ambiguous position would be fixed by centering.
   */
  public func padding(_ value: RelativeBlock.ConstrainedValue) -> RelativeBlock {
    return relative(top: value, leading: value, bottom: value, trailing: value)
  }

  /**
   .padding modifier is similar with .relative but something different.
   Different with that, Not specified edges pin to edge with 0 padding.

   Ambiguous position would be fixed by centering.
   */
  @_disfavoredOverload
  public func padding(_ value: CGFloat) -> RelativeBlock {
    return padding(.exact(value))
  }

  /**
   .padding modifier is similar with .relative but something different.
   Different with that, Not specified edges pin to edge with 0 padding.

   - the values would be used as `exact`.
   */
  public func padding(_ edgeInsets: UIEdgeInsets) -> RelativeBlock {
    return relative(edgeInsets)
  }

  /**
   .padding modifier is similar with .relative but something different.
   Different with that, Not specified edges pin to edge with 0 padding.
   */
  public func padding(_ edges: Edge.Set, _ value: RelativeBlock.ConstrainedValue) -> RelativeBlock {

    return relative(
      top: edges.contains(.top) ? value : 0,
      leading: edges.contains(.leading) ? value : 0,
      bottom: edges.contains(.bottom) ? value : 0,
      trailing: edges.contains(.trailing) ? value : 0
    )

  }

  /**
   .padding modifier is similar with .relative but something different.
   Different with that, Not specified edges pin to edge with 0 padding.
   */
  @_disfavoredOverload
  public func padding(_ edges: Edge.Set, _ value: CGFloat) -> RelativeBlock {
    return padding(edges, .exact(value))
  }

}
