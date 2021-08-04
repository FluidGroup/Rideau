import UIKit

/// [MondrianLayout]
/// A descriptor that lays out the content and overlay content in the parent layout element.
public struct OverlayBlock:
  _LayoutBlockType
{

  // MARK: - Properties

  public var name: String = "Overlay"

  public var _layoutBlockNode: _LayoutBlockNode {
    .overlay(self)
  }

  public let content: _LayoutBlockNode
  public let overlayContent: _LayoutBlockNode

  // MARK: - Initializers

  init(
    content: _LayoutBlockNode,
    overlayContent: _LayoutBlockNode
  ) {

    self.content = content
    self.overlayContent = overlayContent

  }

  // MARK: - Functions

  public func setupConstraints(parent: _LayoutElement, in context: LayoutBuilderContext) {

    setupContent: do {

      switch content {
      case .view(let c):
        context.register(viewConstraint: c)
        context.add(
          constraints: c.makeConstraintsToEdge(parent)
        )
      case .relative(let c as _LayoutBlockType),
           .vStack(let c as _LayoutBlockType),
           .hStack(let c as _LayoutBlockType),
           .zStack(let c as _LayoutBlockType),
           .overlay(let c as _LayoutBlockType),
           .background(let c as _LayoutBlockType):
        c.setupConstraints(parent: parent, in: context)
      }
    }

    setupOverlay: do {

      switch overlayContent {

      case .view(let c):

        context.register(viewConstraint: c)

        context.add(
          constraints: c.makeConstraintsToEdge(parent)
        )

      case .relative(let c as _LayoutBlockType),
           .vStack(let c as _LayoutBlockType),
           .hStack(let c as _LayoutBlockType),
           .zStack(let c as _LayoutBlockType),
           .overlay(let c as _LayoutBlockType),
           .background(let c as _LayoutBlockType):

        let overlayLayoutGuide = context.makeLayoutGuide(identifier: "Overlay")

        context.add(
          constraints:
            overlayLayoutGuide.mondrian.layout.edges(.to(parent)).makeConstraints()
        )

        c.setupConstraints(
          parent: .init(layoutGuide: overlayLayoutGuide),
          in: context
        )

      }

    }

  }

}
