import UIKit
import XCTest
@testable import Rideau

@MainActor
final class PresentationLayoutTests: XCTestCase {

  func testPresentationUsesFinalFrameForTheFullWindowBackdrop() {
    let (controller, context) = presentSheet()

    XCTAssertEqual(controller.view.frame, context.containerView.bounds)
    XCTAssertEqual(controller.backgroundView.frame, controller.view.bounds)
    XCTAssertEqual(controller.rideauView.frame, controller.view.bounds)
    XCTAssertEqual(controller.rideauView.containerView.frame.width, 653)
    XCTAssertEqual(context.completed, true)
  }

  func testBackdropFollowsContainerResizingWhileSheetKeepsItsWidthLimit() {
    let (controller, context) = presentSheet()

    for size in [CGSize(width: 466, height: 678), CGSize(width: 951, height: 669)] {
      context.containerView.frame.size = size
      context.containerView.layoutIfNeeded()
      controller.view.layoutIfNeeded()

      XCTAssertEqual(controller.view.frame, context.containerView.bounds)
      XCTAssertEqual(controller.backgroundView.frame, controller.view.bounds)
      XCTAssertEqual(controller.rideauView.frame, controller.view.bounds)
      XCTAssertEqual(controller.rideauView.containerView.frame.width, min(size.width - 16, 653))
    }
  }

  private func presentSheet() -> (RideauViewController, PresentationContext) {
    let controller = RideauViewController(
      bodyViewController: UIViewController(),
      configuration: .init {
        $0.snapPoints = [.fraction(0.5), .fraction(1)]
        $0.horizontalLayout = .adaptive(maximumWidth: 653)
      },
      initialSnapPoint: .fraction(0.5),
      resizingOption: .resizeToVisibleArea
    )
    controller.view.frame = CGRect(x: 0, y: 0, width: 466, height: 678)
    controller.view.layoutIfNeeded()

    let context = PresentationContext(
      presented: controller,
      finalFrame: CGRect(x: 0, y: 0, width: 951, height: 669)
    )
    RideauPresentTransitionController(targetSnapPoint: .fraction(0.5), backgroundColor: .black)
      .animateTransition(using: context)
    controller.view.layoutIfNeeded()
    return (controller, context)
  }
}

/// Supplies the destination geometry that UIKit owns during a presentation.
@MainActor
private final class PresentationContext: NSObject, UIViewControllerContextTransitioning {

  let containerView: UIView
  private let presented: UIViewController
  private let destinationFrame: CGRect
  private(set) var completed: Bool?

  let isAnimated = false
  let isInteractive = false
  let transitionWasCancelled = false
  let presentationStyle = UIModalPresentationStyle.overFullScreen
  let targetTransform = CGAffineTransform.identity

  init(presented: UIViewController, finalFrame: CGRect) {
    self.presented = presented
    self.destinationFrame = finalFrame
    self.containerView = UIView(frame: finalFrame)
    super.init()
  }

  func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
    key == .to ? presented : nil
  }

  func view(forKey key: UITransitionContextViewKey) -> UIView? {
    key == .to ? presented.view : nil
  }

  func initialFrame(for vc: UIViewController) -> CGRect { vc.view.frame }
  func finalFrame(for vc: UIViewController) -> CGRect { vc === presented ? destinationFrame : .zero }
  func completeTransition(_ didComplete: Bool) { completed = didComplete }
  func updateInteractiveTransition(_ percentComplete: CGFloat) {}
  func finishInteractiveTransition() {}
  func cancelInteractiveTransition() {}
  func pauseInteractiveTransition() {}
}
