import UIKit

/// [MondrianLayout]
///
/// A descriptor that lays out the contents horizontally.
public struct HStackBlock:
  _LayoutBlockType,
  _LayoutBlockNodeConvertible
{

  /// Alignment option for ``HStackBlock``
  public enum YAxisAlignment {
    
    /// In ``HStackBlock``
    case top

    /// In ``HStackBlock``
    case center

    /// In ``HStackBlock``
    case bottom

    /// In ``HStackBlock``
    case fill
  }

  // MARK: - Properties

  public var name: String = "HStack"

  public var _layoutBlockNode: _LayoutBlockNode {
    return .hStack(self)
  }

  public var spacing: CGFloat
  public var alignment: YAxisAlignment
  public var elements: [HStackContentBuilder.Component]

  // MARK: - Initializers

  public init(
    spacing: CGFloat = 0,
    alignment: YAxisAlignment = .center,
    @HStackContentBuilder elements: () -> [HStackContentBuilder.Component]
  ) {
    self.spacing = spacing
    self.alignment = alignment
    self.elements = elements()
  }

  // MARK: - Functions

  public func setupConstraints(parent: _LayoutElement, in context: LayoutBuilderContext) {

    guard elements.isEmpty == false else {
      return
    }

    func align(layoutElement: _LayoutElement, alignment: YAxisAlignment) {

      /// When top, center, bottom. to shrink itself to minimum fitting size.
      func makeShrinkingWeakConstraints() -> [NSLayoutConstraint] {
        return [
          layoutElement.topAnchor.constraint(equalTo: parent.topAnchor).setPriority(
            .fittingSizeLevel
          ),
          layoutElement.bottomAnchor.constraint(equalTo: parent.bottomAnchor).setPriority(
            .fittingSizeLevel
          ),
        ]
      }

      switch alignment {
      case .top:
        context.add(
          constraints: [
            layoutElement.topAnchor.constraint(equalTo: parent.topAnchor),
            layoutElement.bottomAnchor.constraint(
              lessThanOrEqualTo: parent.bottomAnchor
            ),

          ] + makeShrinkingWeakConstraints()
        )
      case .center:
        context.add(
          constraints: [
            layoutElement.topAnchor.constraint(greaterThanOrEqualTo: parent.topAnchor),
            layoutElement.bottomAnchor.constraint(
              lessThanOrEqualTo: parent.bottomAnchor
            ),
            layoutElement.centerYAnchor.constraint(equalTo: parent.centerYAnchor),
          ] + makeShrinkingWeakConstraints()
        )
      case .bottom:
        context.add(
          constraints: [
            layoutElement.topAnchor.constraint(greaterThanOrEqualTo: parent.topAnchor),
            layoutElement.bottomAnchor.constraint(equalTo: parent.bottomAnchor),

          ] + makeShrinkingWeakConstraints()
        )
      case .fill:
        context.add(constraints: [
          layoutElement.topAnchor.constraint(equalTo: parent.topAnchor),
          layoutElement.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
        ])
      }
    }

    var boxes: [_LayoutElement] = []

    for (index, element) in elements.optimizedSpacing().enumerated() {

      func appendSpacingIfNeeded() {
        if spacing > 0, index != elements.indices.last {
          let spacingGuide = context.makeLayoutGuide(identifier: "HStackBlock.Spacing")
          boxes.append(.init(layoutGuide: spacingGuide))
          context.add(constraints: [
            spacingGuide.widthAnchor.constraint(equalToConstant: spacing)
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

        let newLayoutGuide = context.makeLayoutGuide(identifier: "HStackBlock.Spacer")
        boxes.append(.init(layoutGuide: newLayoutGuide))

        if spacer.expands {
          context.add(constraints: [
            newLayoutGuide.widthAnchor.constraint(greaterThanOrEqualToConstant: spacer.minLength)
          ])
        } else {
          context.add(constraints: [
            newLayoutGuide.widthAnchor.constraint(equalToConstant: spacer.minLength)
          ])
        }

        align(layoutElement: .init(layoutGuide: newLayoutGuide), alignment: alignment)

      }

    }

    let firstBox = boxes.first!

    let lastBox = boxes.dropFirst().reduce(firstBox) { previousBox, box in

      context.add(constraints: [
        box.leadingAnchor.constraint(
          equalTo: previousBox.trailingAnchor,
          constant: 0
        )
      ])

      return box
    }

    context.add(constraints: [
      firstBox.leadingAnchor.constraint(
        equalTo: parent.leadingAnchor,
        constant: 0
      )
    ])

    context.add(constraints: [
      lastBox.trailingAnchor.constraint(
        equalTo: parent.trailingAnchor,
        constant: 0
      )
    ])

  }

}
