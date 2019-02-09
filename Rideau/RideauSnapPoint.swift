//
// Rideau
//
// Copyright (c) 2019 muukii
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

public enum RideauSnapPoint : Hashable {
  
  case fraction(CGFloat)
  case pointsFromTop(CGFloat)
  case pointsFromBottom(CGFloat)
  case autoPointsFromBottom
  
  public static let hidden: RideauSnapPoint = .fraction(-0.1)
  public static let full: RideauSnapPoint = .fraction(1)
}

struct ResolvedSnapPoint : Hashable, Comparable {
  static func < (lhs: ResolvedSnapPoint, rhs: ResolvedSnapPoint) -> Bool {
    return lhs.pointsFromTop < rhs.pointsFromTop
  }
  
  let pointsFromTop: CGFloat
  
  let source: RideauSnapPoint
  
  init(_ pointsFromSafeAreaTop: CGFloat, source: RideauSnapPoint) {
    self.pointsFromTop = pointsFromSafeAreaTop.rounded()
    self.source = source
  }
}

struct ResolvedSnapPointRange : Hashable {
  
  let start: ResolvedSnapPoint
  let end: ResolvedSnapPoint
  
  init(_ a: ResolvedSnapPoint, b: ResolvedSnapPoint) {
    
    if a < b {
      self.start = a
      self.end = b
    } else {
      self.start = b
      self.end = a
    }
    
  }
  
  func pointCloser(by point: CGFloat) -> ResolvedSnapPoint? {
    
    if ClosedRange.init(uncheckedBounds: (start.pointsFromTop, end.pointsFromTop)).contains(point) {
      
      let first = abs(point - start.pointsFromTop)
      let second = abs(end.pointsFromTop - point)
      
      if first > second {
        return end
      } else {
        return start
      }
      
    } else {
      return nil
    }
  }
  
}
