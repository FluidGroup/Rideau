import SwiftUI

@available(iOS 14, *)
struct SwiftUIRideau<Content: View>: UIViewControllerRepresentable {

  final class Coordinator {
    let hostingController: UIHostingController<Content>

    init(hostingController: UIHostingController<Content>) {
      self.hostingController = hostingController
    }
  }

  let content: Content

  init(@ViewBuilder conetnt: () -> Content) {
    self.content = conetnt()
  }

  func makeCoordinator() -> Coordinator {
    return .init(hostingController: .init(rootView: content))
  }

  func makeUIViewController(context: Context) -> RideauViewController {

    RideauViewController(
      bodyViewController: context.coordinator.hostingController,
      configuration: .init(
        snapPoints: [.fraction(0.1), .fraction(1)],
        topMarginOption: .fromSafeArea(0)
      ),
      initialSnapPoint: .fraction(1),
      resizingOption: .noResize
    )

  }

  func updateUIViewController(_ uiViewController: RideauViewController, context: Context) {
    context.coordinator.hostingController.rootView = content

    uiViewController.rideauView.move(to: .fraction(1), animated: true, completion: {})
  }

}

extension View {
//
//  public func rideau<Content: View>(
//    isPresented: Binding<Bool>,
//    onDismiss: (() -> Void)?,
//    @ViewBuilder content: () -> Content
//  ) -> some View {
//
//  }

}

#if DEBUG

@available(iOS 14, *)
enum Preview_Rideau: PreviewProvider {

  static var previews: some View {

    Group {
      ContentView()
    }

  }

  struct ContentView: View {

    @State var count: Int = 0

    var body: some View {
      ZStack {
        Color.blue
          .ignoresSafeArea()

        SwiftUIRideau(conetnt: {
          ZStack {
            Color.gray

            VStack {
              Text("Hello \(count)")
              Button("up") {
                count += 1
              }
            }
          }
        })
        .ignoresSafeArea()

      }
    }
  }
}

#endif
