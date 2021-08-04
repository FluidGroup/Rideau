
import UIKit

/// MondrianLayout internal protocol
public protocol __LayoutElementConvertible {
  var _layoutElement: _LayoutElement { get }
}

extension UIView: __LayoutElementConvertible {
  /// MondrianLayout internal property
  public var _layoutElement: _LayoutElement {
    return .init(view: self)
  }
}

extension UILayoutGuide: __LayoutElementConvertible {
  /// MondrianLayout internal property
  public var _layoutElement: _LayoutElement {
    return .init(layoutGuide: self)
  }
}

public struct _LayoutElement: __LayoutElementConvertible {

  public enum XAxisAnchor: Equatable {
    case right
    case left
    case leading
    case trailing
    case centerX
  }

  public enum YAxisAnchor: Equatable {
    case top
    case bottom
    case centerY
  }

  public var _layoutElement: _LayoutElement {
    self
  }

  let leadingAnchor: NSLayoutXAxisAnchor
  let trailingAnchor: NSLayoutXAxisAnchor
  let leftAnchor: NSLayoutXAxisAnchor
  let rightAnchor: NSLayoutXAxisAnchor
  let topAnchor: NSLayoutYAxisAnchor
  let bottomAnchor: NSLayoutYAxisAnchor
  let widthAnchor: NSLayoutDimension
  let heightAnchor: NSLayoutDimension
  let centerXAnchor: NSLayoutXAxisAnchor
  let centerYAnchor: NSLayoutYAxisAnchor

  var owningView: UIView? {
    return view?.superview ?? layoutGuide?.owningView
  }

  let view: UIView?
  let layoutGuide: UILayoutGuide?

  public init(view: UIView) {

    self.view = view
    self.layoutGuide = nil

    leadingAnchor = view.leadingAnchor
    trailingAnchor = view.trailingAnchor
    leftAnchor = view.leftAnchor
    rightAnchor = view.rightAnchor
    topAnchor = view.topAnchor
    bottomAnchor = view.bottomAnchor
    widthAnchor = view.widthAnchor
    heightAnchor = view.heightAnchor
    centerXAnchor = view.centerXAnchor
    centerYAnchor = view.centerYAnchor
  }

  public init(layoutGuide: UILayoutGuide) {

    self.view = nil
    self.layoutGuide = layoutGuide

    leadingAnchor = layoutGuide.leadingAnchor
    trailingAnchor = layoutGuide.trailingAnchor
    leftAnchor = layoutGuide.leftAnchor
    rightAnchor = layoutGuide.rightAnchor
    topAnchor = layoutGuide.topAnchor
    bottomAnchor = layoutGuide.bottomAnchor
    widthAnchor = layoutGuide.widthAnchor
    heightAnchor = layoutGuide.heightAnchor
    centerXAnchor = layoutGuide.centerXAnchor
    centerYAnchor = layoutGuide.centerYAnchor

  }

  func anchor(_ type: XAxisAnchor) -> NSLayoutXAxisAnchor {
    switch type {
    case .right:
      return rightAnchor
    case .left:
      return leftAnchor
    case .leading:
      return leadingAnchor
    case .trailing:
      return trailingAnchor
    case .centerX:
      return centerXAnchor
    }
  }

  func anchor(_ type: YAxisAnchor) -> NSLayoutYAxisAnchor {
    switch type {
    case .top:
      return topAnchor
    case .bottom:
      return bottomAnchor
    case .centerY:
      return centerYAnchor
    }
  }
}
