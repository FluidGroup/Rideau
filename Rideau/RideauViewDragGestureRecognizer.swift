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

import Foundation
import UIKit.UIGestureRecognizerSubclass

final class RideauViewDragGestureRecognizer : UIPanGestureRecognizer {
  
  weak var trackingScrollView: UIScrollView?
  
  init() {
    super.init(target: nil, action: nil)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    trackingScrollView = event.findScrollView()
    super.touchesBegan(touches, with: event)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesMoved(touches, with: event)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesEnded(touches, with: event)
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesCancelled(touches, with: event)
  }
}

extension UIEvent {
  
  fileprivate func findScrollView() -> UIScrollView? {
    
    guard
      let firstTouch = allTouches?.first,
      let targetView = firstTouch.view
      else { return nil }
    
    if let scrollView = targetView as? UIScrollView {
      return scrollView
    }
    
    let scrollView = ResponderChainIterator(responder: targetView)
      .first { $0 is UIScrollView }

    return (scrollView as? UIScrollView)
  }
  
}



#if DEBUG

extension UIGestureRecognizer.State {
  
  fileprivate func localized() -> String {
    
    switch self {
    case .possible: return "Possible"
    case .began: return "Began"
    case .changed: return "Changed"
    case .ended: return "Ended"
    case .cancelled: return "Cancelled"
    case .failed: return "Failed"
    }
  }
}

#endif

fileprivate struct ResponderChainIterator : IteratorProtocol, Sequence {
  
  typealias Element = UIResponder
  
  private var currentResponder: UIResponder?
  
  init(responder: UIResponder) {
    currentResponder = responder
  }
  
  mutating func next() -> UIResponder? {
    
    let next = currentResponder?.next
    currentResponder = next
    return next
  }
}
