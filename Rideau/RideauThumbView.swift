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

import UIKit

open class RideauThumbView : UIView {
  
  private let shapeLayer: CAShapeLayer = .init()
  
  public override init(frame: CGRect) {
    super.init(frame: .zero)
    layer.addSublayer(shapeLayer)
    
    shapeLayer.fillColor = UIColor(white: 0, alpha: 0.15).cgColor
  }
  
  open override var intrinsicContentSize: CGSize {
    return CGSize(width: UIView.noIntrinsicMetric, height: 3)
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open override func layoutSublayers(of layer: CALayer) {
    super.layoutSublayers(of: layer)
    
    shapeLayer.frame = bounds
    shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: .infinity).cgPath
  }
}
