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

  init(@ViewBuilder conetnt: () -> Content, onDidDismiss: @escaping @MainActor () -> Void) {
    self.content = conetnt()
    self.onDidDismiss = onDidDismiss
  }

  func makeCoordinator() -> Coordinator {
    return .init(hostingController: .init(rootView: content))
  }

  func makeUIViewController(context: Context) -> RideauHostingController {

    let controller = RideauHostingController(
      bodyViewController: context.coordinator.hostingController,
      configuration: .init(
        snapPoints: [.hidden, .fraction(1)],
        topMarginOption: .fromSafeArea(0)
      ),
      initialSnapPoint: .fraction(1),
      resizingOption: .noResize
    )

    controller.onDidDismiss = onDidDismiss

    return controller

  }

  func updateUIViewController(_ uiViewController: RideauHostingController, context: Context) {

    context.coordinator.hostingController.rootView = content

    uiViewController.rideauView.move(to: .fraction(1), animated: true, completion: {})
  }

}

extension View {

  public func rideau<Content: View>(
    isPresented: Binding<Bool>,
    onDismiss: (() -> Void)?,
    @ViewBuilder content: () -> Content
  ) -> some View {
    modifier(
      SwiftUIRideauModifier(
        isPresented: isPresented,
        body: content()
      )
    )
  }

}

private struct SwiftUIRideauModifier<Body: View>: ViewModifier {

  private let body: Body
  @Binding var isPresented: Bool

  init(isPresented: Binding<Bool>, body: Body) {
    self.body = body
    self._isPresented = isPresented
  }

  func body(content: Content) -> some View {
    ZStack {
      content
      if isPresented {
        SwiftUIRideau(
          conetnt: { body.ignoresSafeArea() },
          onDidDismiss: {
            isPresented = false
          })
        .ignoresSafeArea()
      }
    }
  }
}

final class RideauHostingController: UIViewController {

  // MARK: - Properties

  var onWillDismiss: () -> Void = {}
  var onDidDismiss: () -> Void = {}

  let rideauView: RideauView

  let backgroundView: UIView = .init()

  let backgroundColor: UIColor

  let initialSnapPoint: RideauSnapPoint

  private let bodyViewController: UIViewController
  private let resizingOption: RideauContentContainerView.ResizingOption

  // MARK: - Initializers

  init(
    bodyViewController: UIViewController,
    configuration: RideauView.Configuration,
    initialSnapPoint: RideauSnapPoint,
    resizingOption: RideauContentContainerView.ResizingOption,
    backdropColor: UIColor = UIColor(white: 0, alpha: 0.2),
    usesDismissalPanGestureOnBackdropView: Bool = true
  ) {

    precondition(configuration.snapPoints.contains(initialSnapPoint))

    self.bodyViewController = bodyViewController
    self.resizingOption = resizingOption

    var c = configuration

    c.snapPoints.insert(.hidden)

    self.initialSnapPoint = initialSnapPoint
    self.rideauView = .init(frame: .zero, configuration: c)

    self.backgroundColor = backdropColor

    super.init(nibName: nil, bundle: nil)

    self.backgroundView.backgroundColor = .clear

    do {

      if usesDismissalPanGestureOnBackdropView {

        let pan = UIPanGestureRecognizer()

        backgroundView.addGestureRecognizer(pan)

        rideauView.register(other: pan)

      }

    }

  }

  @available(*, unavailable)
  required init?(
    coder aDecoder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  override func viewDidLoad() {
    super.viewDidLoad()

    do {
      let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackdropView))
      backgroundView.addGestureRecognizer(tap)

      view.addSubview(backgroundView)

      backgroundView.frame = view.bounds
      backgroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

      view.addSubview(rideauView)
      rideauView.frame = view.bounds
      rideauView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

      // To create resolveConfiguration
      view.layoutIfNeeded()

      set(bodyViewController: bodyViewController, to: rideauView, resizingOption: resizingOption)

      view.layoutIfNeeded()
    }

  }

  func set(
    bodyViewController: UIViewController,
    to rideauView: RideauView,
    resizingOption: RideauContentContainerView.ResizingOption
  ) {
    bodyViewController.willMove(toParent: self)
    addChild(bodyViewController)
    rideauView.containerView.set(bodyView: bodyViewController.view, resizingOption: resizingOption)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    rideauView.handlers.willMoveTo = { [weak self] point in

      guard point == .hidden else {
        return
      }

      UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
        self?.backgroundView.backgroundColor = .clear
      }
      .startAnimation()

    }

    rideauView.handlers.didMoveTo = { [weak self] point in

      guard let self = self else { return }

      guard point == .hidden else {
        return
      }

      self.onWillDismiss()
      self.onDidDismiss()

    }

  }

  @objc private dynamic func didTapBackdropView(gesture: UITapGestureRecognizer) {

    onWillDismiss()
    onDidDismiss()

  }
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
}

#endif
