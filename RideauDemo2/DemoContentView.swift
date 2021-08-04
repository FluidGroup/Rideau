
import SwiftUI

struct ContentView: View {

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

import MondrianLayout

final class SampleViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let hosting = UIHostingController(
      rootView: ContentView()
    )

    addChild(hosting)
    view.addSubview(hosting.view)
    hosting.view.mondrian.layout.edges(.toSuperview).activate()
  }

}

final class SampleView: UIView {

  let hosting = UIHostingController(
    rootView: ContentView()
  )

  init() {
    super.init(frame: .zero)
    addSubview(hosting.view)
    hosting.view.mondrian.layout.edges(.toSuperview).activate()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
