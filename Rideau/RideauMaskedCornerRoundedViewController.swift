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

open class RideauMaskedCornerRoundedViewController : UIViewController {
  
  public let contentView: RideauMaskedCornerRoundedView = .init(frame: .zero)
  public let backdropView: UIView = .init()
  
  public convenience init(viewController: UIViewController) {
    self.init()
    set(viewController: viewController)
  }
  
  public init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open override func viewDidLoad() {
    
    view.backgroundColor = .clear
    contentView.layer.cornerRadius = 8
    contentView.layer.masksToBounds = true
    
    contentView.backgroundColor = .white
//    backdropView.backgroundColor = .white
    
    backdropView.layer.shadowColor = UIColor(white: 0, alpha: 1).cgColor
    backdropView.layer.shadowRadius = 10
    backdropView.layer.shadowOpacity = 0.1
    backdropView.layer.shadowOffset = .zero
    
    view.addSubview(backdropView)
    view.addSubview(contentView)
    
    backdropView.frame = view.bounds
    contentView.frame = view.bounds
    
    backdropView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }
  
  open override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    let path = UIBezierPath(
      roundedRect: view.bounds,
      byRoundingCorners: [.topLeft, .topRight],
      cornerRadii: CGSize(width: 8, height: 8)
      )
      .cgPath
    
    backdropView.layer.shadowPath = path
    
  }
  
  public func set(viewController: UIViewController) {
    
    viewController.willMove(toParent: self)
    addChild(viewController)
    contentView.addSubview(viewController.view)
    
    viewController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      viewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
      viewController.view.rightAnchor.constraint(equalTo: contentView.rightAnchor),
      viewController.view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
      viewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      ])
    
  }
}

