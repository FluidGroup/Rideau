import UIKit

public struct ViewBlock: _LayoutBlockNodeConvertible, _DimensionConstraintType,
  Equatable
{

  public var _layoutBlockNode: _LayoutBlockNode {
    return .view(self)
  }

  public let view: UIView

  public var dimensionConstraints: DimensionDescriptor = .init()

  var verticalHuggingPriority: UILayoutPriority?
  var horizontalHuggingPriority: UILayoutPriority?

  var verticalCompressionResistancePriority: UILayoutPriority?
  var horizontalCompressionResistancePriority: UILayoutPriority?

  public init(
    _ view: UIView
  ) {
    self.view = view
  }

  private func _modify(_ modifier: (inout Self) -> Void) -> Self {
    var new = self
    modifier(&new)
    return new
  }

  public func huggingPriority(
    _ axis: NSLayoutConstraint.Axis,
    _ priority: UILayoutPriority = .required
  ) -> Self {
    _modify {
      switch axis {
      case .horizontal:
        $0.horizontalHuggingPriority = priority
      case .vertical:
        $0.verticalHuggingPriority = priority
      @unknown default:
        assertionFailure()
      }
    }
  }

  public func compressionResistancePriority(
    _ axis: NSLayoutConstraint.Axis,
    _ priority: UILayoutPriority = .required
  ) -> Self {
    _modify {
      switch axis {
      case .horizontal:
        $0.horizontalCompressionResistancePriority = priority
      case .vertical:
        $0.verticalCompressionResistancePriority = priority
      @unknown default:
        assertionFailure()
      }
    }
  }

  func makeConstraintsToEdge(_ element: _LayoutElement) -> [NSLayoutConstraint] {
    return
      [
        view.topAnchor.constraint(equalTo: element.topAnchor),
        view.leadingAnchor.constraint(equalTo: element.leadingAnchor),
        view.bottomAnchor.constraint(equalTo: element.bottomAnchor),
        view.trailingAnchor.constraint(equalTo: element.trailingAnchor),
    ]

  }

  func makeApplier() -> () -> Void {

    return { [weak view] in

      guard let view = view else { return }

      if let priority = verticalHuggingPriority {
        view.setContentHuggingPriority(priority, for: .vertical)
      }
      if let priority = horizontalHuggingPriority {
        view.setContentHuggingPriority(priority, for: .horizontal)
      }
      if let priority = verticalCompressionResistancePriority {
        view.setContentCompressionResistancePriority(priority, for: .vertical)
      }
      if let priority = horizontalCompressionResistancePriority {
        view.setContentCompressionResistancePriority(priority, for: .vertical)
      }
    }
  }

  func makeConstraints() -> [NSLayoutConstraint] {
    dimensionConstraints.makeConstraints(for: view)
  }

}
