import UIKit

/// [MondrianLayout]
/// A descriptor that lays out the contents vertically in parent layout element.
public struct VStackBlock:
  _LayoutBlockType
{

  /// Alignment option for ``VStackBlock``
  public enum XAxisAlignment {
    
    /// In ``VStackBlock``
    case leading

    /// In ``VStackBlock``
    case center

    /// In ``VStackBlock``
    case trailing

    /// In ``VStackBlock``
    case fill
  }

  // MARK: - Properties

  public let name = "VStack"

  public var _layoutBlockNode: _LayoutBlockNode {
    return .vStack(self)
  }

  public var spacing: CGFloat
  public var alignment: XAxisAlignment
  public var elements: [VStackContentBuilder.Component]

  // MARK: - Initializers

  public init(
    spacing: CGFloat = 0,
    alignment: XAxisAlignment = .center,
    @VStackContentBuilder elements: () -> [VStackContentBuilder.Component]
  ) {
    self.spacing = spacing
    self.alignment = alignment
    self.elements = elements()
  }

  // MARK: - Functions

  public func setupConstraints(parent: _LayoutElement, in context: LayoutBuilderContext) {

    let startAnchorKeyPath = \_LayoutElement.topAnchor
    let endAnchorKeyPath = \_LayoutElement.bottomAnchor
    let trailingEdgeKeyPath = \_LayoutElement.trailingAnchor
    let leadingEdgeKeyPath = \_LayoutElement.leadingAnchor

    guard elements.isEmpty == false else {
      return
    }

    func align(layoutElement: _LayoutElement, alignment: XAxisAlignment) {

      /// When leading, center, trailing. to shrink itself to minimum fitting size.
      func makeShrinkingWeakConstraints() -> [NSLayoutConstraint] {
        return [
          layoutElement[keyPath: leadingEdgeKeyPath].constraint(
            equalTo: parent[keyPath: leadingEdgeKeyPath]
          ).setPriority(
            .fittingSizeLevel
          ),
          layoutElement[keyPath: trailingEdgeKeyPath].constraint(
            equalTo: parent[keyPath: trailingEdgeKeyPath]
          ).setPriority(
            .fittingSizeLevel
          ),
        ]
      }

      switch alignment {
      case .leading:
        context.add(
          constraints: [
            layoutElement[keyPath: leadingEdgeKeyPath].constraint(
              equalTo: parent[keyPath: leadingEdgeKeyPath]
            ),
            layoutElement[keyPath: trailingEdgeKeyPath].constraint(
              lessThanOrEqualTo: parent[keyPath: trailingEdgeKeyPath]
            ),
          ] + makeShrinkingWeakConstraints()
        )
      case .center:
        context.add(
          constraints: [
            layoutElement[keyPath: leadingEdgeKeyPath].constraint(
              greaterThanOrEqualTo: parent[keyPath: leadingEdgeKeyPath]
            ),
            layoutElement.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
            layoutElement[keyPath: trailingEdgeKeyPath].constraint(
              lessThanOrEqualTo: parent[keyPath: trailingEdgeKeyPath]
            ),
          ] + makeShrinkingWeakConstraints()
        )
      case .trailing:
        context.add(
          constraints: [
            layoutElement[keyPath: leadingEdgeKeyPath].constraint(
              greaterThanOrEqualTo: parent[keyPath: leadingEdgeKeyPath]
            ),
            layoutElement[keyPath: trailingEdgeKeyPath].constraint(
              equalTo: parent[keyPath: trailingEdgeKeyPath]
            ),
          ] + makeShrinkingWeakConstraints()
        )
      case .fill:
        context.add(constraints: [
          layoutElement[keyPath: leadingEdgeKeyPath].constraint(
            equalTo: parent[keyPath: leadingEdgeKeyPath]
          ),
          layoutElement[keyPath: trailingEdgeKeyPath].constraint(
            equalTo: parent[keyPath: trailingEdgeKeyPath]
          ),
        ])
      }
    }

    var boxes: [_LayoutElement] = []

    for (index, element) in elements.optimizedSpacing().enumerated() {

      func appendSpacingIfNeeded() {
        if spacing > 0, index != elements.indices.last {
          let spacingGuide = context.makeLayoutGuide(identifier: "\(name).Spacing")
          boxes.append(.init(layoutGuide: spacingGuide))
          context.add(constraints: [
            spacingGuide.heightAnchor.constraint(equalToConstant: spacing)
          ])
          align(layoutElement: .init(layoutGuide: spacingGuide), alignment: alignment)
        }
      }

      switch element {
      case .content(let content):
        switch content.node {
        case .view(let viewConstraint):

          let view = viewConstraint.view
          context.register(viewConstraint: viewConstraint)
          boxes.append(.init(view: view))

          align(layoutElement: .init(view: view), alignment: content.alignSelf ?? alignment)
          appendSpacingIfNeeded()

        case .background(let c as _LayoutBlockType),
          .overlay(let c as _LayoutBlockType),
          .relative(let c as _LayoutBlockType),
          .vStack(let c as _LayoutBlockType),
          .hStack(let c as _LayoutBlockType),
          .zStack(let c as _LayoutBlockType):

          let newLayoutGuide = context.makeLayoutGuide(identifier: "HStackBlock.\(c.name)")
          c.setupConstraints(parent: .init(layoutGuide: newLayoutGuide), in: context)
          boxes.append(.init(layoutGuide: newLayoutGuide))

          align(
            layoutElement: .init(layoutGuide: newLayoutGuide),
            alignment: content.alignSelf ?? alignment
          )
          appendSpacingIfNeeded()
        }

      case .spacer(let spacer):

        let newLayoutGuide = context.makeLayoutGuide(identifier: "\(name).Spacer")
        boxes.append(.init(layoutGuide: newLayoutGuide))

        if spacer.expands {
          context.add(constraints: [
            newLayoutGuide.heightAnchor.constraint(greaterThanOrEqualToConstant: spacer.minLength)
          ])
        } else {
          context.add(constraints: [
            newLayoutGuide.heightAnchor.constraint(equalToConstant: spacer.minLength)
          ])
        }

        align(layoutElement: .init(layoutGuide: newLayoutGuide), alignment: alignment)

      }

    }

    let firstBox = boxes.first!

    let lastBox = boxes.dropFirst().reduce(firstBox) { previousBox, box in

      context.add(constraints: [
        box.topAnchor.constraint(
          equalTo: previousBox.bottomAnchor,
          constant: 0
        )
      ])

      return box
    }

    context.add(constraints: [
      firstBox[keyPath: startAnchorKeyPath].constraint(
        equalTo: parent[keyPath: startAnchorKeyPath],
        constant: 0
      )
    ])

    context.add(constraints: [
      lastBox[keyPath: endAnchorKeyPath].constraint(
        equalTo: parent[keyPath: endAnchorKeyPath],
        constant: 0
      )
    ])

  }
}
