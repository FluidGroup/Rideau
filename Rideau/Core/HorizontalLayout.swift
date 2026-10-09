#if canImport(UIKit)
import UIKit

extension RideauView.Configuration {

  /// Determines the sheet's width and placement without changing its snap points.
  public enum HorizontalLayout: Equatable {

    /// Extends the sheet across its host, preserving Rideau's original layout.
    case fullWidth

    /// Centers the sheet within the available region, up to the specified width.
    ///
    /// On iOS 27.1 and later, an active vertical division moves the sheet into
    /// the leading region. Horizontal divisions do not change this layout.
    /// The background continues to cover the entire host.
    ///
    /// - Parameters:
    ///   - maximumWidth: A finite, positive width in points.
    ///   - edgeInset: A finite, nonnegative inset from either side of the region.
    case adaptive(maximumWidth: CGFloat, edgeInset: CGFloat = 8)
  }
}

/// Resolves horizontal placement independently of view hierarchy and animation state.
struct ResolvedHorizontalLayout: Equatable {

  let minX: CGFloat
  let width: CGFloat

  init(
    bounds: CGRect,
    layout: RideauView.Configuration.HorizontalLayout,
    divisionRegions: [CGRect],
    layoutDirection: UIUserInterfaceLayoutDirection
  ) {
    switch layout {
    case .fullWidth:
      minX = bounds.minX
      width = bounds.width

    case .adaptive(let maximumWidth, let edgeInset):
      precondition(maximumWidth.isFinite && maximumWidth > 0)
      precondition(edgeInset.isFinite && edgeInset >= 0)

      var region = bounds
      // A division only affects horizontal placement when it splits this host
      // into left and right regions. Ignore divisions outside or across it.
      for division in divisionRegions where
        division.height > division.width &&
        division.maxY > bounds.minY && division.minY < bounds.maxY &&
        division.minX > bounds.minX && division.maxX < bounds.maxX
      {
        if layoutDirection == .rightToLeft {
          let minX = max(region.minX, division.maxX)
          region.size.width = region.maxX - minX
          region.origin.x = minX
        } else {
          region.size.width = min(region.maxX, division.minX) - region.minX
        }
      }

      width = min(maximumWidth, max(0, region.width - 2 * edgeInset))
      minX = region.midX - width / 2
    }
  }
}
#endif
