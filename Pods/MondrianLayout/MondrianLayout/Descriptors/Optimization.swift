import CoreGraphics

extension Array where Element : _StackElementNodeType {

  /// merging continuous spacing into one
  func optimizedSpacing() -> [Element] {

    var spacing: CGFloat = 0
    var expands: Bool = false

    /**

     __X_ _X___X__

     _X_X_X

     */

    var array: [Element] = []

    for element in self {

      if let spacer = element._spacer {

        spacing += spacer.minLength
        expands = spacer.expands ? true : expands

        continue
      }

      if let content = element._content {

        spacing += content.spacingBefore ?? 0

        if spacing > 0 || expands {
          array.append(.spacer(.init(minLength: spacing, expands: expands)))
        }
        array.append(element)

        spacing = content.spacingAfter ?? 0
        expands = false

        continue
      }

      preconditionFailure()

    }

    if spacing > 0 || expands {
      array.append(.spacer(.init(minLength: spacing, expands: expands)))
    }

    return array

  }
}
