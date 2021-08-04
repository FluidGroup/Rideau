import StorybookKit

let book = Book(title: "Rideau Demo") {

  BookSection(title: "Cases") {
    BookNavigationLink(title: "Inline") {

      BookNavigationLink(title: "List") {
        BookPush(title: "Resizing") {
          DemoInlineViewController(
            snapPoints: [.fraction(0.4), .fraction(1)],
            resizingOption: .resizeToVisibleArea,
            contentView: SwiftUIWrapperView.init(content: ListContentView())
          )
        }
        BookPush(title: "NoResizing") {
          DemoInlineViewController(
            snapPoints: [.fraction(0.4), .fraction(1)],
            resizingOption: .noResize,
            contentView: SwiftUIWrapperView.init(content: ListContentView())
          )
        }
      }

      BookNavigationLink(title: "Other") {

        BookSection(title: "Blank view") {
          BookPush(title: "Resizing") {
            DemoInlineViewController(
              snapPoints: [.fraction(0.4), .fraction(1)],
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
              snapPoints: [.fraction(0.4), .fraction(1)],
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
              snapPoints: [.autoPointsFromBottom, .fraction(1)],
              resizingOption: .resizeToVisibleArea,
              contentView: DemoXYScrollableView()
            )
          }

          BookPush(title: "No-resizing") {
            DemoInlineViewController(
              snapPoints: [.autoPointsFromBottom, .fraction(1)],
              resizingOption: .noResize,
              contentView: DemoXYScrollableView()
            )
          }
        }

        BookSection(title: "XY axis scrollable") {
          BookPush(title: "Resizing") {
            DemoInlineViewController(
              snapPoints: [.fraction(0.4), .fraction(1)],
              resizingOption: .resizeToVisibleArea,
              contentView: DemoXYScrollableView()
            )
          }

          BookPush(title: "No-resizing") {
            DemoInlineViewController(
              snapPoints: [.fraction(0.4), .fraction(1)],
              resizingOption: .noResize,
              contentView: DemoXYScrollableView()
            )
          }
        }

      }
    }

    BookNavigationLink(title: "Present - elastic view") {

      BookSection(title: "initial: 0.4") {
        BookPush(title: "Resizing") {
          DemoPresentViewController(
            snapPoints: [.fraction(0.4), .fraction(1)],
            initialSnappoint: .fraction(0.4),
            resizingOption: .resizeToVisibleArea,
            contentView: ResizingVisualizerView()
          )
        }

        BookPush(title: "No resize") {
          DemoPresentViewController(
            snapPoints: [.fraction(0.4), .fraction(1)],
            initialSnappoint: .fraction(0.4),
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
            resizingOption: .resizeToVisibleArea,
            contentView: ResizingVisualizerView()
          )
        }

        BookPush(title: "No resize") {
          DemoPresentViewController(
            snapPoints: [.fraction(0.4), .fraction(1)],
            initialSnappoint: .fraction(1),
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
          resizingOption: .resizeToVisibleArea,
          contentView: SwiftUIWrapperView.init(content: ListContentView())
        )
      }
      BookPush(title: "NoResizing") {
        DemoPresentViewController(
          snapPoints: [.fraction(0.4), .fraction(1)],
          initialSnappoint: .fraction(0.4),
          resizingOption: .noResize,
          contentView: SwiftUIWrapperView.init(content: ListContentView())
        )
      }
    }
  }

}
