//
//  ScrollPanGesture.swift
//  Rideau
//
//  Created by muukii on 2019/02/10.
//  Copyright © 2019 muukii. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

final class ScrollPanGestureRecognizer : UIPanGestureRecognizer {
  
  private weak var trackingScrollView: UIScrollView?
  private var shouldKillScroll: Bool = false
  
  private var onceOperationWhenStartedTracking: () -> Void = {}
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    trackingScrollView = event.findScrollView()
    shouldKillScroll = false
    super.touchesBegan(touches, with: event)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    
    super.touchesMoved(touches, with: event)
    
    if let scrollView = trackingScrollView {
      
      guard
        scrollView.contentOffset.y <= scrollView.contentInset.top
        else {
          shouldKillScroll = true
          setTranslation(.zero, in: view)
          return
      }
      
      if shouldKillScroll {
        
        var contentOffset = scrollView.contentOffset
        contentOffset.y = scrollView.contentInset.top
        if #available(iOS 11.0, *) {
          contentOffset.y += scrollView.adjustedContentInset.top
        }
        scrollView.setContentOffset(contentOffset, animated: false)
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

fileprivate final class ResponderChainIterator : IteratorProtocol, Sequence {
  
  public typealias Element = UIResponder
  
  private var currentResponder: UIResponder?
  
  public init(responder: UIResponder) {
    currentResponder = responder
  }
  
  public func next() -> UIResponder? {
    
    let next = currentResponder?.next
    currentResponder = next
    return next
  }
}
