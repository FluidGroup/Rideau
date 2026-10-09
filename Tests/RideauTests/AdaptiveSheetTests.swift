import UIKit
import XCTest
@testable import Rideau

@MainActor
final class AdaptiveSheetTests: XCTestCase {

  func testFoldRepositionsExistingContentWithoutChangingTheSnapPoint() async throws {
    let body = UIView()
    let rideau = try await makeRideau(body: body, snapPoint: .fraction(0.5))
    let host = try XCTUnwrap(rideau.subviews.first as? RideauHostingView)
    let initialY = rideau.containerView.frame.minY
    XCTAssertEqual(initialY, 339)
    XCTAssertEqual(rideau.containerView.frame.minX, 149)
    XCTAssertEqual(rideau.containerView.frame.width, 653)

    host.divisionRegionProvider = { _ in
      [CGRect(x: 475.5, y: 0, width: 0, height: 669)]
    }
    host.setNeedsLayout()
    host.layoutIfNeeded()
    rideau.layoutIfNeeded()

    XCTAssertEqual(rideau.containerView.frame.minX, 8)
    XCTAssertEqual(rideau.containerView.frame.width, 459.5, accuracy: 0.5)
    XCTAssertEqual(rideau.containerView.frame.minY, initialY)
    XCTAssertTrue(rideau.containerView.currentBodyView === body)

    host.divisionRegionProvider = { _ in [] }
    host.setNeedsLayout()
    host.layoutIfNeeded()
    rideau.layoutIfNeeded()

    XCTAssertEqual(rideau.containerView.frame.minX, 149)
    XCTAssertEqual(rideau.containerView.frame.width, 653)
    XCTAssertEqual(rideau.containerView.frame.minY, initialY)
  }

  func testSelfSizingUsesNarrowedWidthAndKeepsItsSelectedSnapPoint() async throws {
    let body = UILabel()
    body.numberOfLines = 0
    body.font = .systemFont(ofSize: 20)
    body.text = Array(repeating: "The sheet reflows without replacing its content.", count: 10).joined(separator: " ")
    let rideau = try await makeRideau(body: body, snapPoint: .autoPointsFromBottom)
    let host = try XCTUnwrap(rideau.subviews.first as? RideauHostingView)
    let initialHeight = rideau.bounds.maxY - rideau.containerView.frame.minY

    host.divisionRegionProvider = { _ in
      [CGRect(x: 475.5, y: 0, width: 0, height: 669)]
    }
    host.setNeedsLayout()
    host.layoutIfNeeded()
    rideau.layoutIfNeeded()

    let visibleHeight = rideau.bounds.maxY - rideau.containerView.frame.minY
    let fittedHeight = body.systemLayoutSizeFitting(
      CGSize(width: 459.5, height: UIView.layoutFittingCompressedSize.height),
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel
    ).height
    XCTAssertGreaterThan(visibleHeight, initialHeight)
    XCTAssertEqual(visibleHeight, fittedHeight.rounded(), accuracy: 1)
    XCTAssertTrue(rideau.containerView.currentBodyView === body)
  }

  func testDefaultConfigurationKeepsFullWidthAfterResizing() {
    let rideau = RideauView(frame: CGRect(x: 0, y: 0, width: 466, height: 678), configuration: .init())
    rideau.containerView.set(bodyView: UIView(), resizingOption: .noResize)
    rideau.layoutIfNeeded()
    XCTAssertEqual(rideau.containerView.frame.width, 466)

    rideau.frame.size = CGSize(width: 951, height: 669)
    rideau.layoutIfNeeded()
    XCTAssertEqual(rideau.containerView.frame.minX, 0)
    XCTAssertEqual(rideau.containerView.frame.width, 951)
  }

  func testDragContinuesAcrossAFoldAndSettlesAtTheNextSnapPoint() async throws {
    let rideau = try await makeRideau(body: UIView(), snapPoint: .fraction(0.5))
    let host = try XCTUnwrap(rideau.subviews.first as? RideauHostingView)
    let gesture = SampledPanGesture()
    rideau.containerView.addGestureRecognizer(gesture)

    gesture.state = .began
    host.handlePan(gesture: gesture)
    gesture.sampledTranslation = CGPoint(x: 0, y: -250)
    gesture.sampledLocation = CGPoint(x: 200, y: 250)
    gesture.state = .changed
    host.handlePan(gesture: gesture)
    host.setNeedsLayout()
    host.layoutIfNeeded()
    let draggingY = rideau.containerView.frame.minY
    XCTAssertEqual(draggingY, 89)

    host.divisionRegionProvider = { _ in [CGRect(x: 455.5, y: 0, width: 40, height: 669)] }
    host.setNeedsLayout()
    host.layoutIfNeeded()
    XCTAssertEqual(rideau.containerView.frame.minY, draggingY)
    XCTAssertEqual(rideau.containerView.frame.width, 439.5, accuracy: 0.5)

    let settled = expectation(description: "Settles at the expanded snap point")
    rideau.handlers.didMoveTo = { point in
      if point == .fraction(1) { settled.fulfill() }
    }
    gesture.state = .ended
    host.handlePan(gesture: gesture)
    await fulfillment(of: [settled], timeout: 2)
    host.setNeedsLayout()
    host.layoutIfNeeded()
    XCTAssertEqual(rideau.containerView.frame.minY, 8)
  }

  private func makeRideau(body: UIView, snapPoint: RideauSnapPoint) async throws -> RideauView {
    let rideau = RideauView(
      frame: CGRect(x: 0, y: 0, width: 951, height: 669),
      configuration: .init {
        $0.snapPoints = [.hidden, .autoPointsFromBottom, .fraction(0.5), .fraction(1)]
        $0.topMarginOption = .fromTop(8)
        $0.horizontalLayout = .adaptive(maximumWidth: 653)
      }
    )
    rideau.containerView.set(bodyView: body, resizingOption: .noResize)
    rideau.layoutIfNeeded()
    await withCheckedContinuation { continuation in
      rideau.move(to: snapPoint, animated: false) { continuation.resume() }
    }
    let host = try XCTUnwrap(rideau.subviews.first as? RideauHostingView)
    host.setNeedsLayout()
    host.layoutIfNeeded()
    rideau.layoutIfNeeded()
    return rideau
  }
}

/// Feeds deterministic gesture samples through the same handler used by UIKit.
@MainActor
private final class SampledPanGesture: UIPanGestureRecognizer {
  private var sampledState: UIGestureRecognizer.State = .possible
  var sampledTranslation = CGPoint.zero
  var sampledLocation = CGPoint(x: 200, y: 500)

  override var state: UIGestureRecognizer.State {
    get { sampledState }
    set { sampledState = newValue }
  }

  override func translation(in view: UIView?) -> CGPoint { sampledTranslation }
  override func setTranslation(_ translation: CGPoint, in view: UIView?) { sampledTranslation = translation }
  override func velocity(in view: UIView?) -> CGPoint { .zero }
  override func location(in view: UIView?) -> CGPoint { sampledLocation }
}
