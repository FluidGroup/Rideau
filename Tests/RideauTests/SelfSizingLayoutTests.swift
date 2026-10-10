import UIKit
import SwiftUI
import XCTest
@testable import Rideau

@MainActor
final class SelfSizingLayoutTests: XCTestCase {

  func testBodyBoundsNotificationDoesNotSynchronouslyLayOutTheHost() async throws {
    let body = FittingBodyView()
    let rideau = await makeRideau(body: body, resizingOption: .resizeToVisibleArea)
    let host = try XCTUnwrap(rideau.subviews.first as? RideauHostingView)
    var hostLayoutCount = 0
    host.divisionRegionProvider = { _ in
      hostLayoutCount += 1
      return []
    }

    body.fittingHeight = 240
    body.bounds.size.height = 240
    // Deliver the body-bounds notification in isolation, as UIKit does from
    // the container's layout pass, without first starting a parent pass.
    rideau.containerView.layoutSubviews()

    XCTAssertEqual(hostLayoutCount, 0)
    host.layoutIfNeeded()
    XCTAssertGreaterThan(hostLayoutCount, 0)
    XCTAssertEqual(visibleHeight(of: rideau), 240, accuracy: 1)
  }

  func testSizingRequestDuringFittingWaitsUntilTheCurrentPassReturns() async {
    for option in [RideauContentContainerView.ResizingOption.noResize, .resizeToVisibleArea] {
      let body = FittingBodyView()
      let rideau = await makeRideau(body: body, resizingOption: option)
      body.onNextFitting = {
        body.fittingHeight = 240
        body.requestRideauSelfSizingUpdate()
      }

      body.requestRideauSelfSizingUpdate()

      XCTAssertEqual(body.maximumFittingDepth, 1)
      XCTAssertEqual(visibleHeight(of: rideau), 120, accuracy: 1)
      await nextMainQueueTurn()
      XCTAssertEqual(visibleHeight(of: rideau), 240, accuracy: 1)
      XCTAssertTrue(rideau.containerView.currentBodyView === body)
    }
  }

  func testUnanimatedSizingRequestUpdatesTheHeightBeforeReturning() async {
    for option in [RideauContentContainerView.ResizingOption.noResize, .resizeToVisibleArea] {
      let body = FittingBodyView()
      let rideau = await makeRideau(body: body, resizingOption: option)
      body.fittingHeight = 240

      body.requestRideauSelfSizingUpdate()

      XCTAssertEqual(visibleHeight(of: rideau), 240, accuracy: 1)
      XCTAssertTrue(rideau.containerView.currentBodyView === body)
    }
  }

  func testAnimatedSizingMovesThroughAnIntermediateHeightAndCompletes() async throws {
    for duringFitting in [false, true] {
      for option in [RideauContentContainerView.ResizingOption.noResize, .resizeToVisibleArea] {
        let body = FittingBodyView()
        let rideau = await makeRideau(body: body, resizingOption: option)
        let window = attachToWindow(rideau: rideau)
        defer { window.isHidden = true }
        await nextMainQueueTurn()
        try await Task.sleep(nanoseconds: 50_000_000)

        var animators = [UIViewPropertyAnimator(duration: 0.4, curve: .linear)]
        if duringFitting {
          animators.append(UIViewPropertyAnimator(duration: 0.4, curve: .linear))
        }
        let completed = expectation(description: "Every supplied sizing animator completes")
        completed.expectedFulfillmentCount = animators.count
        for animator in animators {
          animator.addCompletion { position in
            XCTAssertEqual(position, .end)
            completed.fulfill()
          }
        }

        if duringFitting {
          body.onNextFitting = {
            body.fittingHeight = 240
            body.requestRideauSelfSizingUpdate()
            body.requestRideauSelfSizingUpdate(animator: animators[0])
          }
          body.requestRideauSelfSizingUpdate()
          XCTAssertEqual(visibleHeight(of: rideau), 120, accuracy: 1)
          XCTAssertTrue(animators.allSatisfy { $0.state == .inactive })
          // A request after the outer pass must join the pending update rather
          // than commit the height before the queued animators start.
          body.requestRideauSelfSizingUpdate()
          body.requestRideauSelfSizingUpdate(animator: animators[1])
          XCTAssertEqual(visibleHeight(of: rideau), 120, accuracy: 1)
        } else {
          body.fittingHeight = 240
          body.requestRideauSelfSizingUpdate(animator: animators[0])
        }

        await nextMainQueueTurn()
        try await Task.sleep(nanoseconds: 100_000_000)
        let presentationFrame = try XCTUnwrap(rideau.containerView.layer.presentation()?.frame)
        let intermediateHeight = rideau.bounds.maxY - presentationFrame.minY
        XCTAssertGreaterThan(intermediateHeight, 120)
        XCTAssertLessThan(intermediateHeight, 240)
        await fulfillment(of: [completed], timeout: 2)
        XCTAssertEqual(visibleHeight(of: rideau), 240, accuracy: 1)
        XCTAssertEqual(body.maximumFittingDepth, 1)
      }
    }
  }

  func testHostingContentSettlesAfterTextSafeAreaAndFoldChanges() async throws {
    for option in [RideauContentContainerView.ResizingOption.noResize, .resizeToVisibleArea] {
      let hosting = UIHostingController(rootView: FittingText(text: "Short content"))
      let rideau = await makeRideau(body: hosting.view, resizingOption: option)
      let window = attachToWindow(rideau: rideau)
      defer { window.isHidden = true }
      let root = try XCTUnwrap(window.rootViewController)
      root.addChild(hosting)
      hosting.didMove(toParent: root)
      root.additionalSafeAreaInsets = UIEdgeInsets(top: 12, left: 8, bottom: 20, right: 8)
      root.view.layoutIfNeeded()
      rideau.containerView.requestRideauSelfSizingUpdate(animator: nil)
      let initialHeight = visibleHeight(of: rideau)

      hosting.rootView = FittingText(text: Array(repeating: "Content reflows when the sheet changes width.", count: 8).joined(separator: " "))
      hosting.view.invalidateIntrinsicContentSize()
      rideau.containerView.requestRideauSelfSizingUpdate(animator: nil)
      XCTAssertGreaterThan(visibleHeight(of: rideau), initialHeight)
      let host = try XCTUnwrap(rideau.subviews.first as? RideauHostingView)

      for size in [CGSize(width: 466, height: 678), CGSize(width: 951, height: 669)] {
        rideau.frame.size = size
        host.divisionRegionProvider = { _ in [] }
        rideau.layoutIfNeeded()
        let wideHeight = visibleHeight(of: rideau)
        host.divisionRegionProvider = { _ in
          [CGRect(x: 475.5, y: 0, width: 0, height: 669)]
        }
        host.setNeedsLayout()
        host.layoutIfNeeded()
        XCTAssertEqual(rideau.containerView.frame.width, min(size.width - 16, 459.5), accuracy: 0.5)
        XCTAssertGreaterThanOrEqual(visibleHeight(of: rideau), wideHeight)
        let settledHeight = visibleHeight(of: rideau)
        for _ in 0..<3 {
          rideau.containerView.requestRideauSelfSizingUpdate(animator: nil)
          XCTAssertEqual(visibleHeight(of: rideau), settledHeight, accuracy: 1)
        }
        XCTAssertTrue(rideau.containerView.currentBodyView === hosting.view)
      }
    }
  }

  private func makeRideau(
    body: UIView,
    resizingOption: RideauContentContainerView.ResizingOption
  ) async -> RideauView {
    let rideau = RideauView(
      frame: CGRect(x: 0, y: 0, width: 951, height: 669),
      configuration: .init {
        $0.snapPoints = [.hidden, .autoPointsFromBottom]
        $0.topMarginOption = .fromTop(8)
        $0.horizontalLayout = .adaptive(maximumWidth: 640)
      }
    )
    rideau.containerView.set(bodyView: body, resizingOption: resizingOption)
    rideau.layoutIfNeeded()
    await withCheckedContinuation { continuation in
      rideau.move(to: .autoPointsFromBottom, animated: false) { continuation.resume() }
    }
    rideau.layoutIfNeeded()
    return rideau
  }

  private func visibleHeight(of rideau: RideauView) -> CGFloat {
    rideau.bounds.maxY - rideau.containerView.frame.minY
  }

  private func attachToWindow(rideau: RideauView) -> UIWindow {
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 951, height: 669))
    let root = UIViewController()
    window.rootViewController = root
    root.view.addSubview(rideau)
    window.makeKeyAndVisible()
    window.layoutIfNeeded()
    rideau.layoutIfNeeded()
    return window
  }

  private func nextMainQueueTurn() async {
    await withCheckedContinuation { continuation in
      DispatchQueue.main.async { continuation.resume() }
    }
  }
}

/// Uses SwiftUI's real hosting and text fitting, including propagated safe areas.
private struct FittingText: View {
  let text: String

  var body: some View {
    Text(text)
      .font(.system(size: 20))
      .padding(12)
      .fixedSize(horizontal: false, vertical: true)
  }
}

/// Reports a deterministic preferred height and can request another update
/// once during fitting, reproducing layout reentry without an unbounded loop.
@MainActor
private final class FittingBodyView: UIView, RideauContentType {
  var fittingHeight: CGFloat = 120
  var onNextFitting: (() -> Void)?
  private var fittingDepth = 0
  private(set) var maximumFittingDepth = 0

  override func systemLayoutSizeFitting(
    _ targetSize: CGSize,
    withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
    verticalFittingPriority: UILayoutPriority
  ) -> CGSize {
    fittingDepth += 1
    maximumFittingDepth = max(maximumFittingDepth, fittingDepth)
    defer { fittingDepth -= 1 }
    let callback = onNextFitting
    onNextFitting = nil
    callback?()
    return CGSize(width: targetSize.width, height: fittingHeight)
  }
}
