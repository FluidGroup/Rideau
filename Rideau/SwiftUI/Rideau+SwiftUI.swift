import SwiftUI
import UIKit

@available(iOS 14, *)
extension View {

  /**
   Displays a Rideau when a binding to a Boolean value that you provide is true.
   */
  public func rideau<Content: View>(
    configuration: RideauView.Configuration = .init(snapPoints: [.hidden, .fraction(1)]),
    initialSnapPoint: RideauSnapPoint = .fraction(1),
    isPresented: Binding<Bool>,
    onDismiss: (() -> Void)? = nil,
    @ViewBuilder content: () -> Content
  ) -> some View {
    modifier(
      SwiftUIRideauBooleanModifier(
        configuration: configuration,
        initialSnapPoint: initialSnapPoint,
        isPresented: isPresented,
        onDismiss: onDismiss ?? {},
        body: content()
      )
    )

  }

  /**
   Displays a Rideau using the given item as a data source for the Rideau’s content.
   */
  public func rideau<Item: Identifiable, Content: View>(
    configuration: RideauView.Configuration = .init(snapPoints: [.hidden, .fraction(1)]),
    initialSnapPoint: RideauSnapPoint = .fraction(1),
    item: Binding<Item?>,
    onDismiss: (() -> Void)? = nil,
    @ViewBuilder content: @escaping (Item) -> Content
  ) -> some View {

    modifier(
      SwiftUIRideauItemModifier(
        configuration: configuration,
        initialSnapPoint: initialSnapPoint,
        item: item,
        onDismiss: onDismiss ?? {},
        body: content
      )
    )
  }

}

public struct SheetContainerModifier: ViewModifier {

  public let backgroundColor: Color

  public init(backgroundColor: Color = Color.init(UIColor.systemBackground)) {
    self.backgroundColor = backgroundColor
  }

  public func body(content: Content) -> some View {

    VStack {

      RoundedRectangle(cornerRadius: 1000)
        .frame(width: 64, height: 6)
        .foregroundColor(Color.init(white: 1, opacity: 0.8))

      ZStack {
        Rectangle()
          .fill(backgroundColor)
          .mask(Mask())
          // to hide a border on screen bottom
          .padding(.bottom, -100)

        VStack(spacing: 0) {
          content
          Spacer(minLength: 0)
        }
      }
    }

  }

  struct Mask: UIViewRepresentable {

    func updateUIView(_ uiView: UIView, context: Context) {

    }

    func makeUIView(context: Context) -> UIView {
      let view = UIView()
      view.layer.cornerRadius = 24
      view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
      view.layer.cornerCurve = .continuous
      view.backgroundColor = .white
      return view
    }

  }

}

@available(iOS 14, *)
private struct SwiftUIRideau<Content: View>: UIViewControllerRepresentable {

  final class Coordinator {
    let hostingController: UIHostingController<Content>

    init(hostingController: UIHostingController<Content>) {
      self.hostingController = hostingController
    }
  }

  let content: Content
  let onDidDismiss: @MainActor () -> Void
  let configuration: RideauView.Configuration
  let initialSnapPoint: RideauSnapPoint

  init(
    configuration: RideauView.Configuration,
    initialSnapPoint: RideauSnapPoint,
    onDidDismiss: @escaping @MainActor () -> Void,
    @ViewBuilder conetnt: () -> Content
  ) {
    self.configuration = configuration
    self.initialSnapPoint = initialSnapPoint
    self.content = conetnt()
    self.onDidDismiss = onDidDismiss
  }

  func makeCoordinator() -> Coordinator {

    print("Make coordinator")

    let hostingController: UIHostingController<Content> = .init(rootView: content)
    hostingController._disableSafeArea = false
    hostingController.view.backgroundColor = .clear

    return .init(hostingController: hostingController)
  }

  func makeUIViewController(context: Context) -> SwiftUISupports.RideauHostingController {

    print("make")

    let controller = SwiftUISupports.RideauHostingController(
      bodyViewController: context.coordinator.hostingController,
      configuration: configuration,
      resizingOption: .noResize,
      usesDismissalPanGestureOnBackdropView: false,
      hidesByBackgroundTouch: true,
      onViewDidAppear: { viewController in
        viewController.rideauView.move(to: initialSnapPoint, animated: true, completion: {})
      }
    )

    controller.onDidDismiss = onDidDismiss

    return controller

  }

  func updateUIViewController(
    _ uiViewController: SwiftUISupports.RideauHostingController,
    context: Context
  ) {

    context.coordinator.hostingController.rootView = content
    
  }

}

@available(iOS 14, *)
private struct SwiftUIRideauItemModifier<Item: Identifiable, Body: View>: ViewModifier {

  @Binding private var item: Item?
  private let body: (Item) -> Body
  private let onDismiss: () -> Void
  private let configuration: RideauView.Configuration
  private let initialSnapPoint: RideauSnapPoint

  init(
    configuration: RideauView.Configuration,
    initialSnapPoint: RideauSnapPoint,
    item: Binding<Item?>,
    onDismiss: @escaping () -> Void,
    body: @escaping (Item) -> Body
  ) {
    self.body = body
    self.onDismiss = onDismiss
    self._item = item
    self.configuration = configuration
    self.initialSnapPoint = initialSnapPoint

  }

  func body(content: Content) -> some View {
    ZStack {
      content
      if let item {
        SwiftUIRideau(
          configuration: configuration,
          initialSnapPoint: initialSnapPoint,
          onDidDismiss: {
            self.item = nil
          },
          conetnt: {
            body(item)
          }
        )
        .id(item.id)
        .ignoresSafeArea()
      }
    }
  }

}

@available(iOS 14, *)
private struct SwiftUIRideauBooleanModifier<Body: View>: ViewModifier {

  @Binding private var isPresented: Bool
  private let body: Body
  private let onDismiss: () -> Void
  private let configuration: RideauView.Configuration
  private let initialSnapPoint: RideauSnapPoint

  init(
    configuration: RideauView.Configuration,
    initialSnapPoint: RideauSnapPoint,
    isPresented: Binding<Bool>,
    onDismiss: @escaping () -> Void,
    body: Body
  ) {
    self.body = body
    self._isPresented = isPresented
    self.onDismiss = onDismiss
    self.configuration = configuration
    self.initialSnapPoint = initialSnapPoint

  }

  func body(content: Content) -> some View {
    ZStack {
      content
      if isPresented {
        SwiftUIRideau(
          configuration: configuration,
          initialSnapPoint: initialSnapPoint,
          onDidDismiss: {
            onDismiss()
            isPresented = false
          },
          conetnt: {
            body
          }
        )
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
      AutoHeightView()
        .previewDisplayName("AutoHeight")
    }

  }

  struct AutoHeightView: View {
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
      .rideau(
        configuration: .init(snapPoints: [.hidden, .autoPointsFromBottom]),
        initialSnapPoint: .autoPointsFromBottom,
        isPresented: $isPresented,
        onDismiss: nil
      ) {

        ZStack {
          Color.green

          VStack {
            Text("Hello \(count)")
            Text("Hello \(count)")
            Text("Hello \(count)")
            Text("Hello \(count)")
            Button("up") {
              count += 1
            }
            Spacer()
          }
        }
      }
    }
  }

  struct BooleanContentView: View {

    @State var count: Int = 0
    @State var isPresented1 = false
    @State var isPresented2 = false

    var body: some View {
      ZStack {

        Color.yellow
          .ignoresSafeArea()

        VStack {
          Button("Show1") {
            isPresented1 = true
          }

          Button("Show2") {
            isPresented2 = true
          }
        }

      }
      .rideau(isPresented: $isPresented1, onDismiss: nil) {

        ZStack {
          VStack {
            Text("Hello \(count)")
            Button("up") {
              count += 1
            }
          }
          // to display center
          .frame(maxHeight: .infinity)
        }
        .modifier(SheetContainerModifier())
      }
      .rideau(isPresented: $isPresented2, onDismiss: nil) {

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
