import MondrianLayout
import SwiftUI

enum ListContentView_Preview: PreviewProvider {

  static var previews: some View {
    Group {
      let i = 0
      Rectangle()
        .frame(height: 100, alignment: .center)
        .foregroundColor(Color(white: 0.90, opacity: 1))
        .overlay(Text("\(i)"))
        .id(i)
    }
  }
}

struct ListContentView: View {

  var body: some View {

    ZStack {

      Color(white: 1, opacity: 1)
        .edgesIgnoringSafeArea(.all)

      ScrollView(.vertical, showsIndicators: true) {
        VStack {

          ForEach(0..<20) { i in
            Rectangle()
              .frame(height: 100, alignment: .center)
              .foregroundColor(Color(white: 0.90, opacity: 1))
              .overlay(Text("\(i)").foregroundColor(.black))
              .id(i)
          }

        }
      }

    }
  }

}

struct XYScrollableContentView: View {

  var body: some View {

    ZStack {

      Color(white: 1, opacity: 1)
        .edgesIgnoringSafeArea(.all)

      ScrollView(.vertical, showsIndicators: true) {
        VStack {

          TextField.init("Text", text: .constant("Hello"))
            .frame(height: 120)

          ScrollView(.horizontal, showsIndicators: true) {
            HStack {
              ForEach(0..<10) { (i) in

                Rectangle()
                  .frame(width: 50, height: 50, alignment: .center)
                  .foregroundColor(Color(white: 0.90, opacity: 1))

              }
            }
          }

          ForEach(0..<6) { i in
            Text("Section")
            ScrollView(.horizontal, showsIndicators: true) {
              HStack {
                ForEach(0..<10) { (i) in

                  Rectangle()
                    .frame(width: 100, height: 100, alignment: .center)
                    .foregroundColor(Color(white: 0.90, opacity: 1))
                }
              }
            }
            .id(i)
          }

        }
      }

    }
  }

}

final class SampleViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let hosting = UIHostingController(
      rootView: XYScrollableContentView()
    )

    addChild(hosting)
    view.addSubview(hosting.view)
    hosting.view.mondrian.layout.edges(.toSuperview).activate()
  }

}

final class DemoXYScrollableView: SwiftUIWrapperView<XYScrollableContentView> {

  init() {
    super.init(content: .init())
  }

}

class SwiftUIWrapperView<Content: View>: UIView {

  let hosting: UIHostingController<Content>

  init(
    content: Content
  ) {

    self.hosting = UIHostingController(
      rootView: content
    )

    super.init(frame: .zero)
    addSubview(hosting.view)
    hosting.view.mondrian.layout.edges(.toSuperview).activate()
  }

  @available(*, unavailable)
  required init?(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

}
