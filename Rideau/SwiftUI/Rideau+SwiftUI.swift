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
      configuration: .init(snapPoints: [.hidden, .fraction(1)], topMarginOption: .fromSafeArea(0)),
      initialSnapPoint: .fraction(1),
      resizingOption: .noResize
    )
  }

  func updateUIViewController(_ uiViewController: RideauViewController, context: Context) {
    context.coordinator.hostingController.rootView = content
  }

}

#if DEBUG

@available(iOS 14, *)
enum Preview_Rideau: PreviewProvider {

  static var previews: some View {

    Group {
      ZStack {
        Color.blue
        GeometryReader { proxy in
          let _ = print(proxy.size)
          SwiftUIRideau(conetnt: {
            Text("Hello")
          })
        }
      }
    }

  }

}

#endif
