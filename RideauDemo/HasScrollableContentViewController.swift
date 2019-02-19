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

import UIKit

import Rideau

final class HasScrollableContentViewController : UIViewController, RideauViewDelegate {
  
  @IBOutlet weak var scrollView: UIScrollView!
  
  func rideauView(_ rideauView: RideauView, alongsideAnimatorFor range: ResolvedSnapPointRange) -> UIViewPropertyAnimator? {
    return nil
  }
  
  func rideauView(_ rideauView: RideauView, willMoveTo snapPoint: RideauSnapPoint) {
    
    if snapPoint == .autoPointsFromBottom {
//      scrollView.isScrollEnabled = false
      scrollView.alpha = 0.8
    } else {
//      scrollView.isScrollEnabled = true
      scrollView.alpha = 1
    }
    
  }
  
  func rideauView(_ rideauView: RideauView, didMoveTo snapPoint: RideauSnapPoint) {
    
  }
      
}
