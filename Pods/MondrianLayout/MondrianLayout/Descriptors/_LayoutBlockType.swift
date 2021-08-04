
public protocol _LayoutBlockType: _LayoutBlockNodeConvertible {

  var name: String { get }
  func setupConstraints(parent: _LayoutElement, in context: LayoutBuilderContext)
}
