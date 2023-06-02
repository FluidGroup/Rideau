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
  let onDidDismiss: @MainActor () -> Void
  let configuration: RideauView.Configuration

  init(
    configuration: RideauView.Configuration,    
    @ViewBuilder conetnt: () -> Content,
    onDidDismiss: @escaping @MainActor () -> Void
  ) {
    self.configuration = configuration
    self.content = conetnt()
    self.onDidDismiss = onDidDismiss
  }

  func makeCoordinator() -> Coordinator {
    return .init(hostingController: .init(rootView: content))
  }

  func makeUIViewController(context: Context) -> SwiftUISupports.RideauHostingController {

    let controller = SwiftUISupports.RideauHostingController(
      bodyViewController: context.coordinator.hostingController,
      configuration: configuration,
      resizingOption: .noResize,
      usesDismissalPanGestureOnBackdropView: false,
      hidesByBackgroundTouch: false
    )

    controller.onDidDismiss = onDidDismiss

    return controller

  }

  func updateUIViewController(_ uiViewController: SwiftUISupports.RideauHostingController, context: Context) {

    context.coordinator.hostingController.rootView = content

    uiViewController.rideauView.move(to: .fraction(0.5), animated: true, completion: {})
  }

}

extension View {

  public func rideau<Content: View>(
    isPresented: Binding<Bool>,
    onDismiss: (() -> Void)? = nil,
    @ViewBuilder content: () -> Content
  ) -> some View {
    modifier(
      SwiftUIRideauBooleanModifier(
        isPresented: isPresented,
        onDismiss: onDismiss ?? {},
        body: content()
      )
    )

  }

  public func rideau<Item: Identifiable, Content: View>(
    item: Binding<Item?>,
    onDismiss: (() -> Void)? = nil,
    @ViewBuilder content: @escaping (Item) -> Content
  ) -> some View {

    modifier(
      SwiftUIRideauItemModifier(
        item: item,
        onDismiss: onDismiss ?? {},
        body: content
      )
    )
  }


}

private struct SwiftUIRideauItemModifier<Item: Identifiable, Body: View>: ViewModifier {

  private let body: (Item) -> Body
  @Binding var item: Item?
  private let onDismiss: () -> Void

  init(item: Binding<Item?>, onDismiss: @escaping () -> Void, body: @escaping (Item) -> Body) {
    self.body = body
    self.onDismiss = onDismiss
    self._item = item
  }

  func body(content: Content) -> some View {
    ZStack {
      content
      if let item {
        SwiftUIRideau(
          conetnt: { body(item) },
          onDidDismiss: {
            self.item = nil
          })
        .ignoresSafeArea()
        .id(item.id)
      }
    }
  }

}

private struct SwiftUIRideauBooleanModifier<Body: View>: ViewModifier {

  @Binding private var isPresented: Bool
  private let body: Body
  private let onDismiss: () -> Void

  init(isPresented: Binding<Bool>, onDismiss: @escaping () -> Void, body: Body) {
    self.body = body
    self._isPresented = isPresented
    self.onDismiss = onDismiss
  }

  func body(content: Content) -> some View {
    ZStack {
      content
      if isPresented {
        SwiftUIRideau(
          conetnt: { body },
          onDidDismiss: {
            onDismiss()
            isPresented = false
          })
        .ignoresSafeArea()
      }
    }
  }
}


#if DEBUG

@available(iOS 14, *)
enum Preview_Rideau: PreviewProvider {

  static var previews: some View {

    Group {
      BooleanContentView()
        .previewDisplayName("Boolean")
      ItemContentView()
        .previewDisplayName("Item")
    }

  }

  struct BooleanContentView: View {

    @State var count: Int = 0
    @State var isPresented = false

    var body: some View {
      ZStack {

        Color.yellow
          .ignoresSafeArea()

        Button("Show") {
          isPresented = true
        }

      }
      .rideau(isPresented: $isPresented, onDismiss: nil) {

        ZStack {
          Color.green

          VStack {
            Text("Hello \(count)")
            Button("up") {
              count += 1
            }
          }
        }
      }
    }
  }

  struct ItemContentView: View {

    struct Item: Identifiable {
      var id: String
      var name: String
    }

    @State var count: Int = 0
    @State var item: Item?

    var body: some View {
      ZStack {

        Color.yellow
          .ignoresSafeArea()

        VStack {
          Button("up \(count)") {
            count += 1
          }

          Button("A") {
            item = .init(id: "A", name: "A")
            Task {
              try? await Task.sleep(nanoseconds: 1_000_000_000)
              count += 1
            }
          }

          Button("B") {
            item = .init(id: "B", name: "B")
          }
        }

      }
      .rideau(item: $item) { item in

        ZStack {
          Color.green

          VStack {
            Text("This is \(item.name)")
            Button("up") {
              count += 1
            }
            DemoList()
          }
        }
      }

    }

    struct DemoList: View {

      var body: some View {
        List {
          ForEach(0..<80) { index in
            Text("Hello \(index)")
          }
        }
      }

    }
  }
}

#endif
