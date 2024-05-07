import StorybookKit
import UIKit
import SwiftUIHosting

let book = Book(title: "Rideau Demo") {

  BookSection(title: "Cases") {
    BookNavigationLink(title: "Inline") {

      BookSection(title: "Expansion") {
        BookPush(title: "Demo") {
          DemoInlineViewController(
            makeConfiguration: {
              $0.snapPoints = [.autoPointsFromBottom, .fraction(1)]
            },
            resizingOption: .resizeToVisibleArea,
            contentView: DemoExpandableView()
          )
        }
      }

      BookSection(title: "List") {
        BookPush(title: "Resizing") {
          DemoInlineViewController(
            makeConfiguration: {
              $0.snapPoints = [.fraction(0.3), .fraction(0.6), .fraction(1)]
            },
            resizingOption: .resizeToVisibleArea,
            contentView: SwiftUIWrapperView.init(content: ListContentView())
          )
        }
        BookPush(title: "NoResizing") {
          DemoInlineViewController(
            makeConfiguration: {
              $0.snapPoints = [.fraction(0.3), .fraction(0.6), .fraction(1)]
            },
            resizingOption: .noResize,
            contentView: SwiftUIWrapperView.init(content: ListContentView())
          )
        }
      }

      BookSection(title: "List - allowsBouncing") {
        BookPush(title: "Resizing") {
          DemoInlineViewController(
            makeConfiguration: {
              $0.scrollViewOption.allowsBouncing = true
              $0.snapPoints = [.fraction(0.3), .fraction(0.6), .fraction(1)]
            },
            resizingOption: .resizeToVisibleArea,
            contentView: SwiftUIWrapperView.init(content: ListContentView())
          )
        }
        BookPush(title: "NoResizing") {
          DemoInlineViewController(
            makeConfiguration: {
              $0.scrollViewOption.allowsBouncing = true
              $0.snapPoints = [.fraction(0.3), .fraction(0.6), .fraction(1)]
            },
            resizingOption: .noResize,
            contentView: SwiftUIWrapperView.init(content: ListContentView())
          )
        }
      }

      BookSection(title: "List - no-continuous-scrolling") {
        BookPush(title: "Resizing") {
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
        BookPush(title: "NoResizing") {
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
      }

      BookSection(title: "Resizing visualizer") {
        BookPush(title: "Resizing") {
          DemoInlineViewController(
            makeConfiguration: {
              $0.snapPoints = [.fraction(0.3), .fraction(0.6), .fraction(1)]
            },
            resizingOption: .resizeToVisibleArea,
            contentView: ResizingVisualizerView()
          )
        }
        BookPush(title: "NoResizing") {
          DemoInlineViewController(
            makeConfiguration: {
              $0.snapPoints = [.fraction(0.3), .fraction(0.6), .fraction(1)]
            },
            resizingOption: .noResize,
            contentView: ResizingVisualizerView()
          )
        }
      }

      BookNavigationLink(title: "Other") {

        BookSection(title: "Blank view") {
          BookPush(title: "Resizing") {
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

          BookPush(title: "No-resizing") {
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
        }

        BookSection(title: "XY axis scrollable") {
          BookPush(title: "Resizing") {
            DemoInlineViewController(
              makeConfiguration: {
                $0.snapPoints = [.autoPointsFromBottom, .fraction(1)]
              },
              resizingOption: .resizeToVisibleArea,
              contentView: DemoXYScrollableView()
            )
          }

          BookPush(title: "No-resizing") {
            DemoInlineViewController(
              makeConfiguration: {
                $0.snapPoints = [.autoPointsFromBottom, .fraction(1)]
              },
              resizingOption: .noResize,
              contentView: DemoXYScrollableView()
            )
          }
        }

        BookSection(title: "XY axis scrollable") {
          BookPush(title: "Resizing") {
            DemoInlineViewController(
              makeConfiguration: {
                $0.snapPoints = [.fraction(0.4), .fraction(1)]
              },
              resizingOption: .resizeToVisibleArea,
              contentView: DemoXYScrollableView()
            )
          }

          BookPush(title: "No-resizing") {
            DemoInlineViewController(
              makeConfiguration: {
                $0.snapPoints = [.fraction(0.4), .fraction(1)]
              },
              resizingOption: .noResize,
              contentView: DemoXYScrollableView()
            )
          }
        }

      }
    }

    BookNavigationLink(title: "Present") {
      BookSection(title: "Expansion") {
        BookPush(title: "Demo - resizeToVisibleArea") {
          DemoPresentViewController(
            snapPoints: [.autoPointsFromBottom, .fraction(1)],
            initialSnappoint: .autoPointsFromBottom,
            allowsBouncing: false,
            resizingOption: .resizeToVisibleArea,
            contentView: DemoExpandableView()
          )
        }

        BookPush(title: "Demo - noResize") {
          DemoPresentViewController(
            snapPoints: [.autoPointsFromBottom, .fraction(1)],
            initialSnappoint: .autoPointsFromBottom,
            allowsBouncing: false,
            resizingOption: .noResize,
            contentView: DemoExpandableView()
          )
        }
      }
      BookSection(title: "TextInput") {
        BookPush(title: "Demo") {
          DemoPresentViewController(
            snapPoints: [.pointsFromBottom(120), .fraction(1)],
            initialSnappoint: .pointsFromBottom(120),
            allowsBouncing: false,
            resizingOption: .resizeToVisibleArea,
            contentView: DemoTextInputView()
          )
        }
      }

      BookSection(title: "Keyboard") {
        BookPush(title: "Resizing") {
          DemoPresentViewController(
            snapPoints: [.autoPointsFromBottom],
            initialSnappoint: .autoPointsFromBottom,
            allowsBouncing: true,
            resizingOption: .resizeToVisibleArea,
            contentView: SwiftUIHostingView {
              TextInputView()
            }
          )
        }
        BookPush(title: "NoResizing") {
          DemoPresentViewController(
            snapPoints: [.autoPointsFromBottom],
            initialSnappoint: .autoPointsFromBottom,
            allowsBouncing: true,
            resizingOption: .noResize,
            contentView: SwiftUIHostingView {
              TextInputView()
            }
          )
        }
      }


    }

    BookNavigationLink(title: "Present - elastic view") {

      BookSection(title: "initial: 0.4") {
        BookPush(title: "Resizing") {
          DemoPresentViewController(
            snapPoints: [.fraction(0.4), .fraction(1)],
            initialSnappoint: .fraction(0.4),
            allowsBouncing: false,
            resizingOption: .resizeToVisibleArea,
            contentView: ResizingVisualizerView()
          )
        }

        BookPush(title: "No resize") {
          DemoPresentViewController(
            snapPoints: [.fraction(0.4), .fraction(1)],
            initialSnappoint: .fraction(0.4),
            allowsBouncing: false,
            resizingOption: .noResize,
            contentView: ResizingVisualizerView()
          )
        }
      }

      BookSection(title: "initial: 1") {
        BookPush(title: "Resizing") {
          DemoPresentViewController(
            snapPoints: [.fraction(0.4), .fraction(1)],
            initialSnappoint: .fraction(1),
            allowsBouncing: false,
            resizingOption: .resizeToVisibleArea,
            contentView: ResizingVisualizerView()
          )
        }

        BookPush(title: "No resize") {
          DemoPresentViewController(
            snapPoints: [.fraction(0.4), .fraction(1)],
            initialSnappoint: .fraction(1),
            allowsBouncing: false,
            resizingOption: .noResize,
            contentView: ResizingVisualizerView()
          )
        }
      }
    }

    BookNavigationLink(title: "Present - list view") {
      BookPush(title: "Resizing") {
        DemoPresentViewController(
          snapPoints: [.fraction(0.4), .fraction(1)],
          initialSnappoint: .fraction(0.4),
          allowsBouncing: false,
          resizingOption: .resizeToVisibleArea,
          contentView: SwiftUIWrapperView.init(content: ListContentView())
        )
      }
      BookPush(title: "NoResizing") {
        DemoPresentViewController(
          snapPoints: [.fraction(0.4), .fraction(1)],
          initialSnappoint: .fraction(0.4),
          allowsBouncing: false,
          resizingOption: .noResize,
          contentView: SwiftUIWrapperView.init(content: ListContentView())
        )
      }
    }
  }

}
