//
// Copyright (c) 2020 Eureka, Inc.
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

final class SeparatorView : CodeBasedView {
  
  // MARK: - Initializers
  
  init(
    leftMargin: CGFloat = 0,
    rightMargin: CGFloat = 0,
    backgroundColor: UIColor = .clear,
    separatorColor: UIColor? = nil) {
    
    super.init(frame: .zero)
    
    self.backgroundColor = backgroundColor
    let borderView = UIView()
    
    if #available(iOS 13.0, *) {
      borderView.backgroundColor = separatorColor ?? .separator
    } else {
      borderView.backgroundColor = separatorColor ?? .init(white: 0, alpha: 0.1)
    }
    borderView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(borderView)
    
    let scale = UIScreen.main.scale
    let onePixel = 1 / scale

    NSLayoutConstraint.activate([
        heightAnchor.constraint(equalToConstant: 1.0)
        ])

    NSLayoutConstraint.activate([
        borderView.topAnchor.constraint(equalTo: topAnchor, constant: onePixel / scale),
        borderView.heightAnchor.constraint(equalToConstant: onePixel),
        borderView.rightAnchor.constraint(equalTo: rightAnchor, constant: rightMargin),
        borderView.leftAnchor.constraint(equalTo: leftAnchor, constant: rightMargin)
        ])
  }
  
}
