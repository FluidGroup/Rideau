//
// Rideau
//
// Copyright © 2019 Hiroshi Kimura
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#if canImport(UIKit)
import Foundation
import UIKit

@available(*, deprecated, renamed: "RideauContentContainerView")
public typealias RideauContainerView = RideauContentContainerView

/// Main view
/// This view will be translated with user interaction.
/// Frame.size.height will be set maximum SnapPoint.
/// plus, Frame.size will not change.
public final class RideauContentContainerView: UIView {

  public enum ResizingOption {
    case resizeToVisibleArea
    case noResize
  }

  /**
   A layout guide that is available to touch.

   Attached to safe-area
   */
  public let accessibleAreaLayoutGuide: UILayoutGuide = .init()

  /**
   A layout guide that is available to visible but some of area might be hidden by out of the safe-area.
   */
  public let visibleAreaLayoutGuide: UILayoutGuide = .init()

  public private(set) weak var currentBodyView: UIView?
  public private(set) var currentResizingOption: ResizingOption?

  private var previousSizeOfBodyView: CGSize?

  var didChangeContent: () -> Void = {}

  // MARK: - Initializers

  init() {

    super.init(frame: .zero)

    accessibleAreaLayoutGuide.identifier = "muukii.Rideau.accessibleAreaLayoutGuide"
    visibleAreaLayoutGuide.identifier = "muukii.Rideau.visibleAreaLayoutGuide"
  }

  @available(*, unavailable)
  required init?(
    coder aDecoder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  public func requestUpdateLayout() {
    didChangeContent()
  }

  @available(*, unavailable, message: "Don't add view directly, use set(bodyView: options:)")
  public override func addSubview(_ view: UIView) {
    assertionFailure("Don't add view directly, use set(bodyView: options:)")
    super.addSubview(view)
  }

  public func set(bodyView: UIView, resizingOption: ResizingOption) {

    self.currentResizingOption = resizingOption

    currentBodyView?.removeFromSuperview()
    bodyView.translatesAutoresizingMaskIntoConstraints = false
    super.addSubview(bodyView)
    currentBodyView = bodyView

    switch resizingOption {
    case .noResize:

      NSLayoutConstraint.activate([
        bodyView.topAnchor.constraint(equalTo: topAnchor).setIdentifier("Rideau.noResize.top"),
        bodyView.rightAnchor.constraint(equalTo: rightAnchor).setIdentifier("Rideau.noResize.right"),
        bodyView.leftAnchor.constraint(equalTo: leftAnchor).setIdentifier("Rideau.noResize.left"),
        bodyView.bottomAnchor.constraint(equalTo: bottomAnchor).setIdentifier("Rideau.noResize.bottom"),
      ])

    case .resizeToVisibleArea:

      NSLayoutConstraint.activate([
        bodyView.topAnchor.constraint(equalTo: visibleAreaLayoutGuide.topAnchor).setIdentifier("Rideau.resizeToVisibleArea.top"),
        bodyView.rightAnchor.constraint(equalTo: visibleAreaLayoutGuide.rightAnchor).setIdentifier("Rideau.resizeToVisibleArea.right"),
        bodyView.leftAnchor.constraint(equalTo: visibleAreaLayoutGuide.leftAnchor).setIdentifier("Rideau.resizeToVisibleArea.left"),
        bodyView.heightAnchor.constraint(equalToConstant: 0).setPriority(.fittingSizeLevel).setIdentifier("Rideau.resizeToVisibleArea.height.disambiguous"),
        bodyView.bottomAnchor.constraint(equalTo: visibleAreaLayoutGuide.bottomAnchor).setIdentifier("Rideau.resizeToVisibleArea.bottom"),
      ])

    }

  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    if previousSizeOfBodyView != currentBodyView?.bounds.size {
      previousSizeOfBodyView = currentBodyView?.bounds.size
      didChangeContent()
    }
  }

  func setOwner(_ owner: RideauInternalView) {

    addLayoutGuide(accessibleAreaLayoutGuide)
    addLayoutGuide(visibleAreaLayoutGuide)

    let priority = UILayoutPriority.required // (UILayoutPriority.defaultHigh.rawValue - 1)

    visible: do {

      NSLayoutConstraint.activate(
        [
          visibleAreaLayoutGuide.topAnchor.constraint(equalTo: topAnchor).setPriority(priority),
          visibleAreaLayoutGuide.rightAnchor.constraint(equalTo: rightAnchor),
          visibleAreaLayoutGuide.leftAnchor.constraint(equalTo: leftAnchor),
          visibleAreaLayoutGuide.bottomAnchor.constraint(equalTo: owner.bottomAnchor).setPriority(priority),
        ]
      )
    }

    accessible: do {

      NSLayoutConstraint.activate(
        [
          accessibleAreaLayoutGuide.rightAnchor.constraint(equalTo: rightAnchor),
          accessibleAreaLayoutGuide.leftAnchor.constraint(equalTo: leftAnchor),
          accessibleAreaLayoutGuide.topAnchor.constraint(equalTo: topAnchor).setPriority(priority),
        ]
      )

      if #available(iOS 11.0, *) {
        accessibleAreaLayoutGuide.bottomAnchor.constraint(equalTo: owner.safeAreaLayoutGuide.bottomAnchor).setPriority(priority)
          .isActive = true
      } else {
        accessibleAreaLayoutGuide.bottomAnchor.constraint(equalTo: owner.bottomAnchor).setPriority(priority)
          .isActive = true
      }

    }

  }
}
#endif
