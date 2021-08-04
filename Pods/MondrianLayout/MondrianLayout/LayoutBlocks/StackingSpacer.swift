import UIKit

@available(*, deprecated, renamed: "StackingSpacer")
public typealias SpacerBlock = StackingSpacer

/// A flexible space that expands along the major axis of its containing stack layout, or on both axes if not contained in a stack.
/// Currently it does work only inside stacking.
public struct StackingSpacer {

  public let minLength: CGFloat
  public let expands: Bool

  public init(
    minLength: CGFloat,
    expands: Bool = true
  ) {
    self.minLength = minLength
    self.expands = expands
  }
}

