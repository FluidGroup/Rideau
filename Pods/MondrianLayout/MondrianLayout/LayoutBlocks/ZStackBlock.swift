import UIKit

/**
 [MondrianLayout]
 A block that overlays its children, aligning them in both axes as default behavior.

 Examples:

 **Put a view snapping to edge**

 ```swift
 self.mondrian.buildSubviews {
   ZStackBlock {
     backgroundView.viewBlock.relative(0)
   }
 }
 ```

 synonyms:

 ```swift
 ZStackBlock(alignment: .attach(.all)) {
   backgroundView
 }
 ```

 ```swift
 ZStackBlock {
   backgroundView.viewBlock.alignSelf(.attach(.all))
 }
 ```
 */
public struct ZStackBlock:
  _LayoutBlockType
{

  // MARK: - Properties

  public enum XYAxisAlignment {

    /// Anchors in the center with respecting the intrinsic content size each content.
    case center

    /// Attaches the specified edge with respecting the intrinsic content size each content.
    case attach(Edge.Set)
  }

  public var name: String = "ZStack"

  public var _layoutBlockNode: _LayoutBlockNode {
    return .zStack(self)
  }

  public let alignment: XYAxisAlignment
  public let elements: [ZStackContentBuilder.Component]

  // MARK: - Initializers

  public init(
    alignment: XYAxisAlignment = .center,
    @ZStackContentBuilder elements: () -> [ZStackContentBuilder.Component]
  ) {
    self.alignment = alignment
    self.elements = elements()
  }

  // MARK: - Functions

  public func setupConstraints(parent: _LayoutElement, in context: LayoutBuilderContext) {

    elements.forEach { element in

      func perform(current: _LayoutElement, alignment: XYAxisAlignment) {

        var constraints: [NSLayoutConstraint]

        constraints = [
          current.leftAnchor.constraint(greaterThanOrEqualTo: parent.leftAnchor)
            .setInternalIdentifier("ZStack.left"),
          current.topAnchor.constraint(greaterThanOrEqualTo: parent.topAnchor)
            .setInternalIdentifier("ZStack.top"),
          current.rightAnchor.constraint(lessThanOrEqualTo: parent.rightAnchor)
            .setInternalIdentifier("ZStack.right"),
          current.bottomAnchor.constraint(lessThanOrEqualTo: parent.bottomAnchor)
            .setInternalIdentifier("ZStack.bottom"),

          current.widthAnchor.constraint(equalTo: parent.widthAnchor).setPriority(
            .fittingSizeLevel
          )
          .setInternalIdentifier("ZStack.width"),
          current.heightAnchor.constraint(equalTo: parent.heightAnchor).setPriority(
            .fittingSizeLevel
          )
          .setInternalIdentifier("ZStack.height"),
        ]

        switch alignment {
        case .center:

          constraints += [
            current.centerXAnchor.constraint(equalTo: parent.centerXAnchor).setPriority(
              .defaultHigh
            )
            .setInternalIdentifier("ZStack.centerX"),
            current.centerYAnchor.constraint(equalTo: parent.centerYAnchor).setPriority(
              .defaultHigh
            )
            .setInternalIdentifier("ZStack.cenretY"),
          ]

        case .attach(let edges):

          if edges.isEmpty {
            constraints += [
              current.centerXAnchor.constraint(equalTo: parent.centerXAnchor).setPriority(
                .defaultHigh
              )
              .setInternalIdentifier("ZStack.centerX"),
              current.centerYAnchor.constraint(equalTo: parent.centerYAnchor).setPriority(
                .defaultHigh
              )
              .setInternalIdentifier("ZStack.cenretY"),
            ]

          } else {

            if edges.contains(.top) {
              constraints.append(
                current.topAnchor.constraint(equalTo: parent.topAnchor)
              )

            }

            if edges.contains(.trailing) {
              constraints.append(
                current.trailingAnchor.constraint(equalTo: parent.trailingAnchor)
              )

            }

            if edges.contains(.leading) {
              constraints.append(
                current.leadingAnchor.constraint(equalTo: parent.leadingAnchor)
              )
            }

            if edges.contains(.bottom) {
              constraints.append(
                current.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
              )
            }

            if edges.isDisjoint(with: [.leading, .trailing]) {
              constraints.append(
                current.centerXAnchor.constraint(equalTo: parent.centerXAnchor)
              )
            }

            if edges.isDisjoint(with: [.top, .bottom]) {
              constraints.append(
                current.centerYAnchor.constraint(equalTo: parent.centerYAnchor)
              )
            }

          }
        }

        context.add(constraints: constraints)
      }

      switch element.node {
      case .view(let viewConstraint):

        context.register(viewConstraint: viewConstraint)

        perform(
          current: .init(view: viewConstraint.view),
          alignment: element.alignSelf ?? alignment
        )

      case .relative(let relativeConstraint):

        relativeConstraint.setupConstraints(parent: parent, in: context)

      case .background(let c as _LayoutBlockType),
        .overlay(let c as _LayoutBlockType),
        .vStack(let c as _LayoutBlockType),
        .hStack(let c as _LayoutBlockType):

        let newLayoutGuide = context.makeLayoutGuide(identifier: "ZStackBlock.\(c.name)")
        c.setupConstraints(parent: .init(layoutGuide: newLayoutGuide), in: context)

        perform(
          current: .init(layoutGuide: newLayoutGuide),
          alignment: element.alignSelf ?? alignment
        )

      case .zStack(let stackConstraint):

        stackConstraint.setupConstraints(parent: parent, in: context)

      }
    }

  }

}

public protocol _ZStackItemConvertible {
  var _zStackItem: _ZStackItem { get }
}

extension _ZStackItemConvertible {
  public func alignSelf(_ alignment: ZStackBlock.XYAxisAlignment) -> _ZStackItem {
    var item = _zStackItem
    item.alignSelf = alignment
    return item
  }
}

public struct _ZStackItem: _ZStackItemConvertible {

  public var _zStackItem: _ZStackItem { self }

  public let node: _LayoutBlockNode
  public var alignSelf: ZStackBlock.XYAxisAlignment? = nil
}

@resultBuilder
public enum ZStackContentBuilder {
  public typealias Component = _ZStackItem

  public static func buildBlock(_ nestedComponents: [Component]...) -> [Component] {
    return nestedComponents.flatMap { $0 }
  }

  public static func buildExpression(_ views: [UIView]...) -> [Component] {
    return views.flatMap { $0 }.map {
      return .init(node: .view(.init($0)))
    }
  }

  public static func buildExpression<View: UIView>(_ view: View) -> [Component] {
    return [
      .init(node: .view(.init(view)))
    ]
  }
  
  public static func buildExpression<View: UIView>(_ view: View?) -> [Component] {
    guard let view = view else { return [] }
    return buildExpression(view)
  }

  public static func buildExpression<Block: _ZStackItemConvertible>(
    _ block: Block
  ) -> [Component] {
    return [block._zStackItem]
  }

  public static func buildExpression(_ blocks: [_ZStackItemConvertible]...) -> [Component] {
    return blocks.flatMap { $0 }.map { $0._zStackItem }
  }

}
