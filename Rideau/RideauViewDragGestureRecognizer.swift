//
//  ScrollPanGesture.swift
//  Rideau
//
//  Created by muukii on 2019/02/10.
//  Copyright © 2019 muukii. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

final class RideauViewDragGestureRecognizer : UIPanGestureRecognizer {
  
  private weak var trackingScrollView: UIScrollView?
  
  private var onceOperationWhenStartedTracking: () -> Void = {}
  
  private var oldTranslation: CGPoint?
    
  private unowned let rideauInternalView: RideauInternalView
  
  init(rideauInternalView: RideauInternalView) {
    self.rideauInternalView = rideauInternalView
    super.init(target: nil, action: nil)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    trackingScrollView = event.findScrollView()
    oldTranslation = nil
    super.touchesBegan(touches, with: event)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    
    super.touchesMoved(touches, with: event)
    
    if let scrollView = trackingScrollView, scrollView.isScrollEnabled {
      
      let isScrollingDown = velocity(in: view).y > 0
      let isScrollViewOnTop = scrollView.contentOffset.y <= _getActualContentInset(from: scrollView).top
      
      if rideauInternalView.willReachedMostTop(translation: .zero) {
        if !isScrollingDown || !isScrollViewOnTop {
          setTranslation(.zero, in: view)
          oldTranslation = scrollView.panGestureRecognizer.translation(in: scrollView.panGestureRecognizer.view)
        } else {
          scrollView.panGestureRecognizer.setTranslation(oldTranslation ?? .zero, in: scrollView.panGestureRecognizer.view)
        }
      } else {
        scrollView.panGestureRecognizer.setTranslation(oldTranslation ?? .zero, in: scrollView.panGestureRecognizer.view)
      }
    }
    
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

private func _getActualContentInset(from scrollView: UIScrollView) -> UIEdgeInsets {
  
  var insets = UIEdgeInsets.zero
  
  insets.top = scrollView.contentInset.top
  insets.right = scrollView.contentInset.right
  insets.left = scrollView.contentInset.left
  insets.bottom = scrollView.contentInset.bottom
  
  if #available(iOS 11, *) {
    insets.top = scrollView.adjustedContentInset.top
    insets.right = scrollView.adjustedContentInset.right
    insets.left = scrollView.adjustedContentInset.left
    insets.bottom = scrollView.adjustedContentInset.bottom
  }
  
  return insets
  
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
