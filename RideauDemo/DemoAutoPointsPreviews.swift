import Rideau
import SwiftUI
import UIKit

// MARK: - Inline · SwiftUI auto sizing

#Preview("Inline / SwiftUI autoPoints / Resize") {
  ViewControllerContainer {
    DemoInlineViewController(
      snapPoints: [.autoPointsFromBottom, .fraction(1)],
      resizingOption: .resizeToVisibleArea,
      contentView: SwiftUIAutoSizingDemoView()
    )
  }
}

#Preview("Inline / SwiftUI autoPoints / NoResize") {
  ViewControllerContainer {
    DemoInlineViewController(
      snapPoints: [.autoPointsFromBottom, .fraction(1)],
      resizingOption: .noResize,
      contentView: SwiftUIAutoSizingDemoView()
    )
  }
}

// MARK: - Present · SwiftUI auto sizing

#Preview("Present / SwiftUI autoPoints / Resize") {
  ViewControllerContainer {
    DemoPresentViewController(
      snapPoints: [.autoPointsFromBottom, .fraction(1)],
      initialSnapPoint: .autoPointsFromBottom,
      resizingOption: .resizeToVisibleArea,
      contentView: SwiftUIAutoSizingDemoView()
    )
  }
}

#Preview("Present / SwiftUI autoPoints / NoResize") {
  ViewControllerContainer {
    DemoPresentViewController(
      snapPoints: [.autoPointsFromBottom, .fraction(1)],
      initialSnapPoint: .autoPointsFromBottom,
      resizingOption: .noResize,
      contentView: SwiftUIAutoSizingDemoView()
    )
  }
}
