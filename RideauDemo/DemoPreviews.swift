import Rideau
import SwiftUI
import UIKit

// MARK: - Inline · Expandable

#Preview("Inline / Expandable / Resize") {
  ViewControllerContainer {
    DemoInlineViewController(
      snapPoints: [.autoPointsFromBottom, .fraction(1)],
      resizingOption: .resizeToVisibleArea,
      contentView: DemoExpandableView()
    )
  }
}

// MARK: - Inline · List

#Preview("Inline / List / Resize") {
  ViewControllerContainer {
    DemoInlineViewController(
      snapPoints: [.fraction(0.3), .fraction(0.6), .fraction(1)],
      resizingOption: .resizeToVisibleArea,
      contentView: SwiftUIWrapperView(content: ListContentView())
    )
  }
}

#Preview("Inline / List / NoResize") {
  ViewControllerContainer {
    DemoInlineViewController(
      snapPoints: [.fraction(0.3), .fraction(0.6), .fraction(1)],
      resizingOption: .noResize,
      contentView: SwiftUIWrapperView(content: ListContentView())
    )
  }
}

#Preview("Inline / List / NoTracking / Resize") {
  ViewControllerContainer {
    DemoInlineViewController(
      snapPoints: [.fraction(0.3), .fraction(0.6), .fraction(1)],
      scrollViewDetection: .noTracking,
      resizingOption: .resizeToVisibleArea,
      contentView: SwiftUIWrapperView(content: ListContentView())
    )
  }
}

#Preview("Inline / List / NoTracking / NoResize") {
  ViewControllerContainer {
    DemoInlineViewController(
      snapPoints: [.fraction(0.3), .fraction(0.6), .fraction(1)],
      scrollViewDetection: .noTracking,
      resizingOption: .noResize,
      contentView: SwiftUIWrapperView(content: ListContentView())
    )
  }
}

// MARK: - Inline · Resizing visualizer

#Preview("Inline / Resizing visualizer / Resize") {
  ViewControllerContainer {
    DemoInlineViewController(
      snapPoints: [.fraction(0.3), .fraction(0.6), .fraction(1)],
      resizingOption: .resizeToVisibleArea,
      contentView: ResizingVisualizerView()
    )
  }
}

#Preview("Inline / Resizing visualizer / NoResize") {
  ViewControllerContainer {
    DemoInlineViewController(
      snapPoints: [.fraction(0.3), .fraction(0.6), .fraction(1)],
      resizingOption: .noResize,
      contentView: ResizingVisualizerView()
    )
  }
}

// MARK: - Inline · Blank

#Preview("Inline / Blank / Resize") {
  ViewControllerContainer {
    DemoInlineViewController(
      snapPoints: [.fraction(0.4), .fraction(1)],
      resizingOption: .resizeToVisibleArea,
      contentView: DemoBlankView(color: .systemOrange)
    )
  }
}

#Preview("Inline / Blank / NoResize") {
  ViewControllerContainer {
    DemoInlineViewController(
      snapPoints: [.fraction(0.4), .fraction(1)],
      resizingOption: .noResize,
      contentView: DemoBlankView(color: .systemOrange)
    )
  }
}

// MARK: - Inline · Mixed scroll

#Preview("Inline / Mixed scroll / Resize") {
  ViewControllerContainer {
    DemoInlineViewController(
      snapPoints: [.fraction(0.45), .fraction(1)],
      resizingOption: .resizeToVisibleArea,
      contentView: SwiftUIWrapperView(content: MixedAxisScrollContentView())
    )
  }
}

#Preview("Inline / Mixed scroll / NoResize") {
  ViewControllerContainer {
    DemoInlineViewController(
      snapPoints: [.fraction(0.4), .fraction(1)],
      resizingOption: .noResize,
      contentView: SwiftUIWrapperView(content: MixedAxisScrollContentView())
    )
  }
}

// MARK: - Present · Expandable

#Preview("Present / Expandable / Resize") {
  ViewControllerContainer {
    DemoPresentViewController(
      snapPoints: [.autoPointsFromBottom, .fraction(1)],
      initialSnapPoint: .autoPointsFromBottom,
      resizingOption: .resizeToVisibleArea,
      contentView: DemoExpandableView()
    )
  }
}

#Preview("Present / Expandable / NoResize") {
  ViewControllerContainer {
    DemoPresentViewController(
      snapPoints: [.autoPointsFromBottom, .fraction(1)],
      initialSnapPoint: .autoPointsFromBottom,
      resizingOption: .noResize,
      contentView: DemoExpandableView()
    )
  }
}

// MARK: - Present · Text input

#Preview("Present / TextInput") {
  ViewControllerContainer {
    DemoPresentViewController(
      snapPoints: [.pointsFromBottom(120), .fraction(1)],
      initialSnapPoint: .pointsFromBottom(120),
      resizingOption: .resizeToVisibleArea,
      contentView: DemoTextInputView()
    )
  }
}

// MARK: - Present · Resizing visualizer

#Preview("Present / Visualizer / initial 0.4 / Resize") {
  ViewControllerContainer {
    DemoPresentViewController(
      snapPoints: [.fraction(0.4), .fraction(1)],
      initialSnapPoint: .fraction(0.4),
      resizingOption: .resizeToVisibleArea,
      contentView: ResizingVisualizerView()
    )
  }
}

#Preview("Present / Visualizer / initial 0.4 / NoResize") {
  ViewControllerContainer {
    DemoPresentViewController(
      snapPoints: [.fraction(0.4), .fraction(1)],
      initialSnapPoint: .fraction(0.4),
      resizingOption: .noResize,
      contentView: ResizingVisualizerView()
    )
  }
}

#Preview("Present / Visualizer / initial 1 / Resize") {
  ViewControllerContainer {
    DemoPresentViewController(
      snapPoints: [.fraction(0.4), .fraction(1)],
      initialSnapPoint: .fraction(1),
      resizingOption: .resizeToVisibleArea,
      contentView: ResizingVisualizerView()
    )
  }
}

#Preview("Present / Visualizer / initial 1 / NoResize") {
  ViewControllerContainer {
    DemoPresentViewController(
      snapPoints: [.fraction(0.4), .fraction(1)],
      initialSnapPoint: .fraction(1),
      resizingOption: .noResize,
      contentView: ResizingVisualizerView()
    )
  }
}

// MARK: - Present · List

#Preview("Present / List / Resize") {
  ViewControllerContainer {
    DemoPresentViewController(
      snapPoints: [.fraction(0.4), .fraction(1)],
      initialSnapPoint: .fraction(0.4),
      resizingOption: .resizeToVisibleArea,
      contentView: SwiftUIWrapperView(content: ListContentView())
    )
  }
}

#Preview("Present / List / NoResize") {
  ViewControllerContainer {
    DemoPresentViewController(
      snapPoints: [.fraction(0.4), .fraction(1)],
      initialSnapPoint: .fraction(0.4),
      resizingOption: .noResize,
      contentView: SwiftUIWrapperView(content: ListContentView())
    )
  }
}

// MARK: - Present · Mixed scroll

#Preview("Present / Mixed scroll / Resize") {
  ViewControllerContainer {
    DemoPresentViewController(
      snapPoints: [.fraction(0.45), .fraction(1)],
      initialSnapPoint: .fraction(0.45),
      resizingOption: .resizeToVisibleArea,
      contentView: SwiftUIWrapperView(content: MixedAxisScrollContentView())
    )
  }
}

#Preview("Present / Mixed scroll / NoResize") {
  ViewControllerContainer {
    DemoPresentViewController(
      snapPoints: [.fraction(0.45), .fraction(1)],
      initialSnapPoint: .fraction(0.45),
      resizingOption: .noResize,
      contentView: SwiftUIWrapperView(content: MixedAxisScrollContentView())
    )
  }
}
