import StorybookKit

let book = Book(title: "Rideau Demo") {

  BookSection(title: "Cases") {
    BookNavigationLink(title: "Inline") {

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
}
