import UIKit

extension MondrianNamespace where Base : UIView {

  /**
   Applies the layout constraints
   Adding subviews included in layout
   */
  @discardableResult
  @available(*, deprecated, renamed: "buildSubviews")
  public func buildSublayersLayout<Block: _LayoutBlockType>(
    build: () -> Block
  ) -> LayoutBuilderContext {
    buildSubviews(build: build)
  }

  @discardableResult
  @available(*, deprecated, renamed: "buildSubviews")
  public func buildSublayersLayout(
    build: () -> LayoutContainer
  ) -> LayoutBuilderContext {
    buildSubviews(build: build)
  }

  /**
   Applies the layout constraints
   Adding subviews included in layout

   You might use ``LayoutContainer`` from describe beginning in order to support safe-area.
   */
  @discardableResult
  public func buildSubviews<Block: _LayoutBlockType>(
    build: () -> Block
  ) -> LayoutBuilderContext {

    let context = LayoutBuilderContext(targetView: base)
    let container = build()
    container.setupConstraints(parent: .init(view: base), in: context)
    context.prepareViewHierarchy()
    context.activate()

    return context
  }

  /**
   Applies the layout constraints
   Adding subviews included in layout
   */
  @discardableResult
  public func buildSubviews(
    build: () -> LayoutContainer
  ) -> LayoutBuilderContext {

    let context = LayoutBuilderContext(targetView: base)
    let container = build()
    container.setupConstraints(parent: base, in: context)
    context.prepareViewHierarchy()
    context.activate()

    return context
  }

  /// Applies the layout of the dimension in itself.
  public func buildSelfSizing(build: (ViewBlock) -> ViewBlock) {

    let constraint = ViewBlock(base)
    let modifiedConstraint = build(constraint)

    modifiedConstraint.makeApplier()()
    NSLayoutConstraint.activate(
      modifiedConstraint.makeConstraints()
    )

  }

}

extension UIView {

  /// Returns an instance of ViewBlock to describe layout.
  public var viewBlock: ViewBlock {
    .init(self)
  }

  public var hasAmbiguousLayoutRecursively: Bool {

    var hasAmbiguous: Bool = false

    func traverse(_ view: UIView) {

      if view.hasAmbiguousLayout {
        hasAmbiguous = true
      }

      for subview in view.subviews {
        traverse(subview)
      }

    }

    traverse(self)

    return hasAmbiguous
  }

}
