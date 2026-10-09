import Rideau
import SwiftUI
import UIKit

// Each scenario is also discoverable in the Storybook catalog.

#Preview("Adaptive width / Safe area") {
  DemoSafeAreaPreview()
    .ignoresSafeArea()
}

#Preview("Adaptive width / Scrollable sheet") {
  DemoPresentViewController(
    snapPoints: [.fraction(0.5), .fraction(1)],
    initialSnappoint: .fraction(0.5),
    allowsBouncing: true,
    resizingOption: .resizeToVisibleArea,
    contentView: SwiftUIWrapperView(content: ListContentView()),
    horizontalLayout: .adaptive(maximumWidth: 653)
  )
}

#Preview("Adaptive width / Self-sizing sheet") {
  DemoPresentViewController(
    snapPoints: [.autoPointsFromBottom, .fraction(1)],
    initialSnappoint: .autoPointsFromBottom,
    allowsBouncing: true,
    resizingOption: .resizeToVisibleArea,
    contentView: DemoExpandableView(),
    horizontalLayout: .adaptive(maximumWidth: 653)
  )
}

#Preview("Inline / Expansion / Demo") {
  DemoInlineViewController(
    makeConfiguration: {
      $0.snapPoints = [.autoPointsFromBottom, .fraction(1)]
    },
    resizingOption: .resizeToVisibleArea,
    contentView: DemoExpandableView()
  )
}

#Preview("Inline / List / Resizing") {
  DemoInlineViewController(
    makeConfiguration: {
      $0.snapPoints = [.fraction(0.3), .fraction(0.6), .fraction(1)]
    },
    resizingOption: .resizeToVisibleArea,
    contentView: SwiftUIWrapperView.init(content: ListContentView())
  )
}

#Preview("Inline / List / NoResizing") {
  DemoInlineViewController(
    makeConfiguration: {
      $0.snapPoints = [.fraction(0.3), .fraction(0.6), .fraction(1)]
    },
    resizingOption: .noResize,
    contentView: SwiftUIWrapperView.init(content: ListContentView())
  )
}

#Preview("Inline / List - allowsBouncing / Resizing") {
  DemoInlineViewController(
    makeConfiguration: {
      $0.scrollViewOption.allowsBouncing = true
      $0.snapPoints = [.fraction(0.3), .fraction(0.6), .fraction(1)]
    },
    resizingOption: .resizeToVisibleArea,
    contentView: SwiftUIWrapperView.init(content: ListContentView())
  )
}

#Preview("Inline / List - allowsBouncing / NoResizing") {
  DemoInlineViewController(
    makeConfiguration: {
      $0.scrollViewOption.allowsBouncing = true
      $0.snapPoints = [.fraction(0.3), .fraction(0.6), .fraction(1)]
    },
    resizingOption: .noResize,
    contentView: SwiftUIWrapperView.init(content: ListContentView())
  )
}

#Preview("Inline / List - no-continuous-scrolling / Resizing") {
  DemoInlineViewController(
    makeConfiguration: {
      $0.scrollViewOption.allowsBouncing = true
      $0.scrollViewOption.scrollViewDetection = .noTracking
      $0.snapPoints = [.fraction(0.3), .fraction(0.6), .fraction(1)]
    },
    resizingOption: .resizeToVisibleArea,
    contentView: SwiftUIWrapperView.init(content: ListContentView())
  )
}

#Preview("Inline / List - no-continuous-scrolling / NoResizing") {
  DemoInlineViewController(
    makeConfiguration: {
      $0.scrollViewOption.allowsBouncing = true
      $0.scrollViewOption.scrollViewDetection = .noTracking
      $0.snapPoints = [.fraction(0.3), .fraction(0.6), .fraction(1)]
    },
    resizingOption: .noResize,
    contentView: SwiftUIWrapperView.init(content: ListContentView())
  )
}

#Preview("Inline / Resizing visualizer / Resizing") {
  DemoInlineViewController(
    makeConfiguration: {
      $0.snapPoints = [.fraction(0.3), .fraction(0.6), .fraction(1)]
    },
    resizingOption: .resizeToVisibleArea,
    contentView: ResizingVisualizerView()
  )
}

#Preview("Inline / Resizing visualizer / NoResizing") {
  DemoInlineViewController(
    makeConfiguration: {
      $0.snapPoints = [.fraction(0.3), .fraction(0.6), .fraction(1)]
    },
    resizingOption: .noResize,
    contentView: ResizingVisualizerView()
  )
}

#Preview("Inline / Other / Blank view / Resizing") {
  DemoInlineViewController(
    makeConfiguration: {
      $0.snapPoints = [.fraction(0.4), .fraction(1)]
    },
    resizingOption: .resizeToVisibleArea,
    contentView: {
      let view = UIView()
      view.backgroundColor = .systemOrange
      return view
    }()
  )
}

#Preview("Inline / Other / Blank view / No-resizing") {
  DemoInlineViewController(
    makeConfiguration: {
      $0.snapPoints = [.fraction(0.4), .fraction(1)]
    },
    resizingOption: .noResize,
    contentView: {
      let view = UIView()
      view.backgroundColor = .systemOrange
      return view
    }()
  )
}

#Preview("Inline / Other / XY scrolling / Self-sizing / Resizing") {
  DemoInlineViewController(
    makeConfiguration: {
      $0.snapPoints = [.autoPointsFromBottom, .fraction(1)]
    },
    resizingOption: .resizeToVisibleArea,
    contentView: DemoXYScrollableView()
  )
}

#Preview("Inline / Other / XY scrolling / Self-sizing / No-resizing") {
  DemoInlineViewController(
    makeConfiguration: {
      $0.snapPoints = [.autoPointsFromBottom, .fraction(1)]
    },
    resizingOption: .noResize,
    contentView: DemoXYScrollableView()
  )
}

#Preview("Inline / Other / XY scrolling / Fractional / Resizing") {
  DemoInlineViewController(
    makeConfiguration: {
      $0.snapPoints = [.fraction(0.4), .fraction(1)]
    },
    resizingOption: .resizeToVisibleArea,
    contentView: DemoXYScrollableView()
  )
}

#Preview("Inline / Other / XY scrolling / Fractional / No-resizing") {
  DemoInlineViewController(
    makeConfiguration: {
      $0.snapPoints = [.fraction(0.4), .fraction(1)]
    },
    resizingOption: .noResize,
    contentView: DemoXYScrollableView()
  )
}

#Preview("Present / Expansion / Demo - resizeToVisibleArea") {
  DemoPresentViewController(
    snapPoints: [.autoPointsFromBottom, .fraction(1)],
    initialSnappoint: .autoPointsFromBottom,
    allowsBouncing: false,
    resizingOption: .resizeToVisibleArea,
    contentView: DemoExpandableView()
  )
}

#Preview("Present / Expansion / Demo - noResize") {
  DemoPresentViewController(
    snapPoints: [.autoPointsFromBottom, .fraction(1)],
    initialSnappoint: .autoPointsFromBottom,
    allowsBouncing: false,
    resizingOption: .noResize,
    contentView: DemoExpandableView()
  )
}

#Preview("Present / TextInput / Demo") {
  DemoPresentViewController(
    snapPoints: [.pointsFromBottom(120), .fraction(1)],
    initialSnappoint: .pointsFromBottom(120),
    allowsBouncing: false,
    resizingOption: .resizeToVisibleArea,
    contentView: DemoTextInputView()
  )
}

#Preview("Present - elastic view / initial: 0.4 / Resizing") {
  DemoPresentViewController(
    snapPoints: [.fraction(0.4), .fraction(1)],
    initialSnappoint: .fraction(0.4),
    allowsBouncing: false,
    resizingOption: .resizeToVisibleArea,
    contentView: ResizingVisualizerView()
  )
}

#Preview("Present - elastic view / initial: 0.4 / No resize") {
  DemoPresentViewController(
    snapPoints: [.fraction(0.4), .fraction(1)],
    initialSnappoint: .fraction(0.4),
    allowsBouncing: false,
    resizingOption: .noResize,
    contentView: ResizingVisualizerView()
  )
}

#Preview("Present - elastic view / initial: 1 / Resizing") {
  DemoPresentViewController(
    snapPoints: [.fraction(0.4), .fraction(1)],
    initialSnappoint: .fraction(1),
    allowsBouncing: false,
    resizingOption: .resizeToVisibleArea,
    contentView: ResizingVisualizerView()
  )
}

#Preview("Present - elastic view / initial: 1 / No resize") {
  DemoPresentViewController(
    snapPoints: [.fraction(0.4), .fraction(1)],
    initialSnappoint: .fraction(1),
    allowsBouncing: false,
    resizingOption: .noResize,
    contentView: ResizingVisualizerView()
  )
}

#Preview("Present - list view / Resizing") {
  DemoPresentViewController(
    snapPoints: [.fraction(0.4), .fraction(1)],
    initialSnappoint: .fraction(0.4),
    allowsBouncing: false,
    resizingOption: .resizeToVisibleArea,
    contentView: SwiftUIWrapperView.init(content: ListContentView())
  )
}

#Preview("Present - list view / NoResizing") {
  DemoPresentViewController(
    snapPoints: [.fraction(0.4), .fraction(1)],
    initialSnappoint: .fraction(0.4),
    allowsBouncing: false,
    resizingOption: .noResize,
    contentView: SwiftUIWrapperView.init(content: ListContentView())
  )
}
