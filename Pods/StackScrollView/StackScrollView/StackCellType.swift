// StackCellType.swift
//
// Copyright (c) 2016 muukii
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

import UIKit

public protocol StackCellType : class {

}

public protocol ManualLayoutStackCellType : StackCellType {

  func size(maxWidth: CGFloat?, maxHeight: CGFloat?) -> CGSize
}

extension StackCellType where Self : UIView {

  public var stackScrollView: StackScrollView? {
    var superview: UIView? = self

    while superview != nil && !(superview is StackScrollView) {
      superview = superview?.superview
    }

    return superview as? StackScrollView
  }
  
  public func scrollToSelf(animated: Bool) {

    stackScrollView?.scroll(to: self, animated: animated)
  }

  public func scrollToSelf(at position: UICollectionView.ScrollPosition, animated: Bool) {
    stackScrollView?.scroll(to: self, at: position, animated: animated)
  }

  public func updateLayout(animated: Bool) {
    invalidateIntrinsicContentSize()
    stackScrollView?.updateLayout(animated: animated)
  }

  public func remove() {
    stackScrollView?.remove(view: self, animated: true)
  }
}
