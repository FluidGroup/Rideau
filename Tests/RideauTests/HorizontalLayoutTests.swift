import XCTest
import UIKit
@testable import Rideau

final class HorizontalLayoutTests: XCTestCase {

  private let bounds = CGRect(x: 0, y: 0, width: 951, height: 669)
  private let division = CGRect(x: 475.5, y: 0, width: 0, height: 669)

  func testFullWidthPreservesOriginalLayout() {
    let layout = resolve(.fullWidth, divisions: [division])
    XCTAssertEqual(layout.minX, 0)
    XCTAssertEqual(layout.width, 951)
  }

  func testAdaptiveLayoutCentersWithinWideBounds() {
    let layout = resolve(.adaptive(maximumWidth: 653))
    XCTAssertEqual(layout.minX, 149)
    XCTAssertEqual(layout.width, 653)
  }

  func testAdaptiveLayoutFitsNarrowBounds() {
    let layout = ResolvedHorizontalLayout(
      bounds: CGRect(x: 20, y: 0, width: 466, height: 678),
      layout: .adaptive(maximumWidth: 653),
      divisionRegions: [],
      layoutDirection: .leftToRight
    )
    XCTAssertEqual(layout.minX, 28)
    XCTAssertEqual(layout.width, 450)
  }

  func testVerticalDivisionMovesSheetIntoLeadingRegion() {
    let layout = resolve(.adaptive(maximumWidth: 653), divisions: [division])
    XCTAssertEqual(layout.minX, 8)
    XCTAssertEqual(layout.width, 459.5)
  }

  func testRightToLeftLayoutUsesRightRegionIncludingDivisionMargin() {
    let layout = resolve(
      .adaptive(maximumWidth: 653),
      divisions: [CGRect(x: 467.5, y: 0, width: 16, height: 669)],
      direction: .rightToLeft
    )
    XCTAssertEqual(layout.minX, 491.5)
    XCTAssertEqual(layout.width, 451.5)
  }

  func testHorizontalAndNonintersectingDivisionsDoNotChangePlacement() {
    let layout = resolve(.adaptive(maximumWidth: 653), divisions: [
      CGRect(x: 0, y: 330, width: 951, height: 9),
      CGRect(x: 1100, y: 0, width: 20, height: 669),
      CGRect(x: 475, y: 900, width: 1, height: 669),
    ])
    XCTAssertEqual(layout.minX, 149)
    XCTAssertEqual(layout.width, 653)
  }

  func testMultipleDivisionsChooseSameRegionRegardlessOfOrder() {
    let divisions = [division, CGRect(x: 700, y: 0, width: 8, height: 669)]
    for direction in [UIUserInterfaceLayoutDirection.leftToRight, .rightToLeft] {
      XCTAssertEqual(
        resolve(.adaptive(maximumWidth: 653), divisions: divisions, direction: direction),
        resolve(.adaptive(maximumWidth: 653), divisions: divisions.reversed(), direction: direction)
      )
    }
  }

  func testInsetsDoNotProduceNegativeWidthInTinyBounds() {
    let layout = ResolvedHorizontalLayout(
      bounds: CGRect(x: 0, y: 0, width: 10, height: 100),
      layout: .adaptive(maximumWidth: 653),
      divisionRegions: [],
      layoutDirection: .leftToRight
    )
    XCTAssertEqual(layout.minX, 5)
    XCTAssertEqual(layout.width, 0)
  }

  private func resolve(
    _ layout: RideauView.Configuration.HorizontalLayout,
    divisions: [CGRect] = [],
    direction: UIUserInterfaceLayoutDirection = .leftToRight
  ) -> ResolvedHorizontalLayout {
    ResolvedHorizontalLayout(
      bounds: bounds,
      layout: layout,
      divisionRegions: divisions,
      layoutDirection: direction
    )
  }
}
