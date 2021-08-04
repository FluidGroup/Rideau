import UIKit

protocol _StackElementNodeType {

  associatedtype ItemType: StackItemType

  static func spacer(_ spacer: StackingSpacer) -> Self
  static func content(_ item: ItemType) -> Self

  var _content: ItemType? { get }
  var _spacer: StackingSpacer? { get }
}

public enum _VStackElementNode: _StackElementNodeType {

  case content(_VStackItem)
  case spacer(StackingSpacer)

  var _content: _VStackItem? {
    guard case .content(let value) = self else {
      return nil
    }
    return value
  }

  var _spacer: StackingSpacer? {
    guard case .spacer(let value) = self else {
      return nil
    }
    return value
  }

}

public enum _HStackElementNode: _StackElementNodeType {

  case content(_HStackItem)
  case spacer(StackingSpacer)

  var _content: _HStackItem? {
    guard case .content(let value) = self else {
      return nil
    }
    return value
  }

  var _spacer: StackingSpacer? {
    guard case .spacer(let value) = self else {
      return nil
    }
    return value
  }

}

public protocol StackItemType {
  var spacingBefore: CGFloat? { get }
  var spacingAfter: CGFloat? { get }
}

public protocol _VStackItemConvertible {
  var _vStackItem: _VStackItem { get }
}

public protocol _HStackItemConvertible {
  var _hStackItem: _HStackItem { get }
}

public struct _VStackItem: _VStackItemConvertible, StackItemType {

  public var _vStackItem: _VStackItem { self }

  public let node: _LayoutBlockNode
  public var alignSelf: VStackBlock.XAxisAlignment? = nil
  public var spacingBefore: CGFloat? = nil
  public var spacingAfter: CGFloat? = nil

}

public struct _HStackItem: _HStackItemConvertible, StackItemType {

  public var _hStackItem: _HStackItem { self }

  public let node: _LayoutBlockNode
  public var alignSelf: HStackBlock.YAxisAlignment? = nil
  public var spacingBefore: CGFloat? = nil
  public var spacingAfter: CGFloat? = nil

}

extension _VStackItemConvertible {

  public func alignSelf(_ alignment: VStackBlock.XAxisAlignment) -> _VStackItem {
    var item = _vStackItem
    item.alignSelf = alignment
    return item
  }

  public func spacingBefore(_ spacing: CGFloat) -> _VStackItem {
    var item = _vStackItem
    item.spacingBefore = (item.spacingBefore ?? 0) + spacing
    return item
  }

  public func spacingAfter(_ spacing: CGFloat) -> _VStackItem {
    var item = _vStackItem
    item.spacingAfter = (item.spacingAfter ?? 0) + spacing
    return item
  }
}

extension _HStackItemConvertible {

  public func alignSelf(_ alignment: HStackBlock.YAxisAlignment) -> _HStackItem {
    var item = _hStackItem
    item.alignSelf = alignment
    return item
  }

  public func spacingBefore(_ spacing: CGFloat) -> _HStackItem {
    var item = _hStackItem
    item.spacingBefore = (item.spacingBefore ?? 0) + spacing
    return item
  }

  public func spacingAfter(_ spacing: CGFloat) -> _HStackItem {
    var item = _hStackItem
    item.spacingAfter = (item.spacingAfter ?? 0) + spacing
    return item
  }
}

@resultBuilder
public enum VStackContentBuilder {
  public typealias Component = _VStackElementNode

  public static func buildBlock(_ nestedComponents: [Component]...) -> [Component] {
    return nestedComponents.flatMap { $0 }
  }

  public static func buildExpression(_ views: [UIView]...) -> [Component] {
    return views.flatMap { $0 }.map {
      .content(.init(node: .view(.init($0))))
    }
  }

  public static func buildExpression<View: UIView>(_ view: View) -> [Component] {
    return [
      .content(.init(node: .view(.init(view))))
    ]
  }

  public static func buildExpression<View: UIView>(_ view: View?) -> [Component] {
    guard let view = view else { return [] }
    return buildExpression(view)
  }

  public static func buildExpression<Block: _VStackItemConvertible>(
    _ block: Block
  ) -> [Component] {
    return [.content(block._vStackItem)]
  }

  public static func buildExpression(_ blocks: [_VStackItemConvertible]...) -> [Component] {
    return blocks.flatMap { $0 }.map { .content($0._vStackItem) }
  }

  public static func buildExpression(_ spacer: StackingSpacer) -> [Component] {
    return [.spacer(spacer)]
  }

}

@resultBuilder
public enum HStackContentBuilder {
  public typealias Component = _HStackElementNode

  public static func buildBlock(_ nestedComponents: [Component]...) -> [Component] {
    return nestedComponents.flatMap { $0 }
  }

  public static func buildExpression(_ views: [UIView]...) -> [Component] {
    return views.flatMap { $0 }.map {
      .content(.init(node: .view(.init($0))))
    }
  }

  public static func buildExpression<View: UIView>(_ view: View) -> [Component] {
    return [
      .content(.init(node: .view(.init(view))))
    ]
  }

  public static func buildExpression<View: UIView>(_ view: View?) -> [Component] {
    guard let view = view else { return [] }
    return buildExpression(view)
  }

  public static func buildExpression<Block: _HStackItemConvertible>(
    _ block: Block
  ) -> [Component] {
    return [.content(block._hStackItem)]
  }

  public static func buildExpression(_ blocks: [_HStackItemConvertible]...) -> [Component] {
    return blocks.flatMap { $0 }.map { .content($0._hStackItem) }
  }

  public static func buildExpression(_ spacer: StackingSpacer) -> [Component] {
    return [.spacer(spacer)]
  }

}
