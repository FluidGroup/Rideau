//
//  HaltScrollView.swift
//  Rideau
//
//  Created by muukii on 2019/03/14.
//  Copyright © 2019 Hiroshi Kimura. All rights reserved.
//

import UIKit

final class ScrollStopper {
  
  private var scrollObserver: NSKeyValueObservation?
  private var shouldStop: Bool = false
  private var previousValue: CGPoint?
  
  init() {
    
  }
  
  func stop() {
    shouldStop = true
  }
  
  func unstop() {
    shouldStop = false
  }
  
  func startTracking(scrollView: UIScrollView) {
    scrollObserver?.invalidate()
    scrollObserver = scrollView.observe(\.contentOffset, options: .old) { [weak self, weak _scrollView = scrollView] scrollView, change in
      
      guard let scrollView = _scrollView else { return }
      guard let self = self else { return }
      self.handleScrollViewEvent(scrollView: scrollView, change: change)
    }
  }
  
  func endTracking() {
    scrollObserver?.invalidate()
    scrollObserver = nil
  }
  
  private func handleScrollViewEvent(scrollView: UIScrollView, change: NSKeyValueObservedChange<CGPoint>) {
    
    // For debugging
    
    guard let oldValue = change.oldValue else { return }
    
    guard shouldStop else {
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
