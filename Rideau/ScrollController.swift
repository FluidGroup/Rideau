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

final class ScrollController {

  private var scrollObserver: NSKeyValueObservation!
  private(set) var isLocking: Bool = false
  private var previousValue: CGPoint?
  let scrollView: UIScrollView

  init(scrollView: UIScrollView) {
    self.scrollView = scrollView
    scrollObserver = scrollView.observe(\.contentOffset, options: .old) { [weak self, weak _scrollView = scrollView] scrollView, change in

      guard let scrollView = _scrollView else { return }
      guard let self = self else { return }
      self.handleScrollViewEvent(scrollView: scrollView, change: change)
    }
  }

  deinit {
    endTracking()
  }

  func lockScrolling() {
    isLocking = true
  }

  func unlockScrolling() {
    isLocking = false
  }

  func endTracking() {
    unlockScrolling()
    scrollObserver.invalidate()
  }

  private func handleScrollViewEvent(scrollView: UIScrollView, change: NSKeyValueObservedChange<CGPoint>) {

    // For debugging

    guard let oldValue = change.oldValue else { return }

    guard isLocking else {
      scrollView.showsVerticalScrollIndicator = true
      return
    }

    guard scrollView.contentOffset != oldValue else { return }

    guard oldValue != previousValue else { return }

    previousValue = scrollView.contentOffset

    scrollView.setContentOffset(oldValue, animated: false)
    scrollView.showsVerticalScrollIndicator = false
  }

}
#endif
