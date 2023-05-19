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
import UIKit

@available(*, deprecated, renamed: "RideauContentType")
public typealias RideauContainerBodyType = RideauContentType

/**
 An protocol that indicates whether the view shows in RideauView.
 Providing methods to control RideauView from the content.
 */
public protocol RideauContentType {

}

extension UIView {
  @inline(__always)
  func _owningRideauContainerView() -> RideauContentContainerView? {
    var view: UIView? = superview

    while view != nil {
      guard let containerView = view as? RideauContentContainerView else {
        view = view?.superview
        continue
      }
      return containerView
    }
    return nil
  }
  
  @inline(__always)
  func _requestRideauSelfSizingUpdate(animator: UIViewPropertyAnimator? = nil) {
    _owningRideauContainerView()?.requestRideauSelfSizingUpdate(animator: animator)
  }
}

extension RideauContentType where Self: UIView {

  public func owningRideauContainerView() -> RideauContentContainerView? {
    _owningRideauContainerView()
  }

  public func owningRideauView() -> RideauView? {
    owningRideauContainerView()?.hostingView?.parentView
  }

  @available(*, deprecated, renamed: "requestRideauSelfSizingUpdate")
  public func requestUpdateLayout() {
    requestRideauSelfSizingUpdate(animator: nil)
  }

  /**
   Requests update for the self-sizing in using intrinsic content size.
   */
  public func requestRideauSelfSizingUpdate(animator: UIViewPropertyAnimator? = nil) {
    _requestRideauSelfSizingUpdate(animator: animator)
  }
}

extension RideauContentType where Self: UIViewController {

  public func owningRideauContainerView() -> RideauContentContainerView? {
    self.view._owningRideauContainerView()
  }

  public func owningRideauView() -> RideauView? {
    owningRideauContainerView()?.hostingView?.parentView
  }

  @available(*, deprecated, renamed: "requestRideauSelfSizingUpdate")
  public func requestUpdateLayout() {
    requestRideauSelfSizingUpdate(animator: nil)
  }

  /**
   Requests update for the self-sizing in using intrinsic content size.
   */
  public func requestRideauSelfSizingUpdate(animator: UIViewPropertyAnimator? = nil) {
    view._requestRideauSelfSizingUpdate(animator: animator)
  }
}
#endif
