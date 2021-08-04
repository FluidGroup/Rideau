import UIKit

public struct DimensionDescriptor: Equatable {

  public struct ConstraintValue: Equatable {
    public var constant: CGFloat
    public var priority: UILayoutPriority
  }
  
  public var aspectRatio: ConstraintValue?

  public var minHeight: ConstraintValue?
  public var minWidth: ConstraintValue?

  public var maxHeight: ConstraintValue?
  public var maxWidth: ConstraintValue?

  public var height: ConstraintValue?
  public var width: ConstraintValue?

  public func makeConstraints(for view: UIView) -> [NSLayoutConstraint] {
    return makeConstraints(for: .init(view: view))
  }

  public func makeConstraints(for layoutGuide: UILayoutGuide) -> [NSLayoutConstraint] {
    return makeConstraints(for: .init(layoutGuide: layoutGuide))
  }

  func makeConstraints(for view: _LayoutElement) -> [NSLayoutConstraint] {
    var constraint: [NSLayoutConstraint] = []

    if let height = height {
      constraint.append(
        view.heightAnchor.constraint(equalToConstant: height.constant)
          .setPriority(height.priority)
          .setInternalIdentifier("ViewConstraints.height")
      )
    }

    if let width = width {
      constraint.append(
        view.widthAnchor.constraint(equalToConstant: width.constant)
          .setPriority(width.priority)
          .setInternalIdentifier("ViewConstraints.width")
      )
    }

    if let minHeight = minHeight {
      constraint.append(
        view.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight.constant).setPriority(
          minHeight.priority
        )
        .setInternalIdentifier("ViewConstraints.minHeight")
      )
    }

    if let width = minWidth {
      constraint.append(
        view.widthAnchor.constraint(greaterThanOrEqualToConstant: width.constant).setPriority(
          width.priority
        )
        .setInternalIdentifier("ViewConstraints.minWidth")
      )
    }

    if let height = maxHeight {
      constraint.append(
        view.heightAnchor.constraint(lessThanOrEqualToConstant: height.constant).setPriority(
          height.priority
        )
        .setInternalIdentifier("ViewConstraints.maxHeight")
      )
    }

    if let width = maxWidth {
      constraint.append(
        view.widthAnchor.constraint(lessThanOrEqualToConstant: width.constant).setPriority(
          width.priority
        )
        .setInternalIdentifier("ViewConstraints.maxWdith")
      )
    }

    if let aspectRatio = aspectRatio {
      constraint.append(
        view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: aspectRatio.constant)
          .setPriority(aspectRatio.priority)
          .setInternalIdentifier("ViewConstraints.aspectRatio")
      )
    }

    return constraint
  }

}

public protocol _DimensionConstraintType {
  var dimensionConstraints: DimensionDescriptor { get set }
}

extension _DimensionConstraintType {

  private func _modify(_ modifier: (inout DimensionDescriptor) -> Void) -> Self {
    var new = self
    modifier(&new.dimensionConstraints)
    return new
  }

  /**
   - Parameters:
   - value: Passing nil removes constraints.
   */
  public func aspectRatio(_ ratio: CGFloat?, priority: UILayoutPriority = .required) -> Self {
    _modify {
      $0.aspectRatio = ratio.map { .init(constant: $0, priority: priority) }
    }
  }

  /**
   Constrains this view’s dimensions to the aspect ratio of the given size.

   - Parameters:
   - size: Passing nil removes constraints.
   */
  public func aspectRatio(_ size: CGSize?) -> Self {
    aspectRatio(size.map { $0.width / $0.height })
  }

  /**
   - Parameters:
   - value: Passing nil removes constraints.
   */
  public func height(_ value: CGFloat?, priority: UILayoutPriority = .required) -> Self {
    _modify {
      $0.height = value.map { .init(constant: $0, priority: priority) }
    }
  }

  /**
   - Parameters:
   - value: Passing nil removes constraints.
   */
  public func width(_ value: CGFloat?, priority: UILayoutPriority = .required) -> Self {
    _modify {
      $0.width = value.map { .init(constant: $0, priority: priority) }
    }
  }

  /**
   - Parameters:
   - value: Passing nil removes constraints.
   */
  public func minHeight(_ value: CGFloat?, priority: UILayoutPriority = .required) -> Self {
    _modify {
      $0.minHeight = value.map { .init(constant: $0, priority: priority) }
    }
  }

  /**
   - Parameters:
   - value: Passing nil removes constraints.
   */
  public func minWidth(_ value: CGFloat?, priority: UILayoutPriority = .required) -> Self {
    _modify {
      $0.minWidth = value.map { .init(constant: $0, priority: priority) }
    }
  }

  /**
   - Parameters:
   - value: Passing nil removes constraints.
   */
  public func maxHeight(_ value: CGFloat?, priority: UILayoutPriority = .required) -> Self {
    _modify {
      $0.maxHeight = value.map { .init(constant: $0, priority: priority) }
    }
  }

  /**
   - Parameters:
   - value: Passing nil removes constraints.
   */
  public func maxWidth(_ value: CGFloat?, priority: UILayoutPriority = .required) -> Self {
    _modify {
      $0.maxWidth = value.map { .init(constant: $0, priority: priority) }
    }
  }

  /**
   Set size constraints as specified CGSize

   - Parameters:
   - value: Passing nil removes constraints.
   */
  public func size(_ size: CGSize?, priority: UILayoutPriority = .required) -> Self {
    _modify {
      if let size = size {
        $0.height = .init(constant: size.height, priority: priority)
        $0.width = .init(constant: size.width, priority: priority)
      } else {
        $0.height = nil
        $0.width = nil
      }
    }
  }

  /**
   Set size constraints as square

   - Parameters:
   - value: Passing nil removes constraints.
   */
  public func size(_ length: CGFloat?, priority: UILayoutPriority = .required) -> Self {
    _modify {
      if let length = length {
        $0.height = .init(constant: length, priority: priority)
        $0.width = .init(constant: length, priority: priority)
      } else {
        $0.height = nil
        $0.width = nil
      }
    }
  }
}
