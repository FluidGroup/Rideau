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

open class RideauMaskedCornerRoundedViewController : UIViewController {
  
  public var isThumbVisible: Bool = false {
    didSet {
      
      guard oldValue != isThumbVisible else { return }
      
      if isThumbVisible {
        
        thumbView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(thumbView)
        
        NSLayoutConstraint.activate([
          thumbView.widthAnchor.constraint(equalToConstant: 32),
          thumbView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 4),
          thumbView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
          thumbView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
          ])
        
      } else {
        
        thumbView.removeFromSuperview()
        
      }
    }
  }
  
  public let headerView: UIView = .init()
  public let contentView: RideauMaskedCornerRoundedView = .init(frame: .zero)
  public let backdropView: UIView = .init()
  private lazy var thumbView: RideauThumbView = .init(frame: .zero)
  
  public convenience init(viewController: UIViewController) {
    self.init()
    set(viewController: viewController)
  }
  
  public init() {
    super.init(nibName: nil, bundle: nil)
    
    view.backgroundColor = .clear
    contentView.layer.cornerRadius = 8
    contentView.layer.masksToBounds = true
    
    contentView.backgroundColor = .white
    
    backdropView.layer.shadowColor = UIColor(white: 0, alpha: 1).cgColor
    backdropView.layer.shadowRadius = 10
    backdropView.layer.shadowOpacity = 0.1
    backdropView.layer.shadowOffset = .zero
    
    view.addSubview(backdropView)
    view.addSubview(contentView)
    contentView.addSubview(headerView)
    
    headerView.translatesAutoresizingMaskIntoConstraints = false
    headerView.setContentHuggingPriority(.required, for: .vertical)
    
    NSLayoutConstraint.activate([
      headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
      headerView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
      headerView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
      ])
    
    backdropView.frame = view.bounds
    contentView.frame = view.bounds
    
    backdropView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
  }
  
  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
      viewController.view.topAnchor.constraint(equalTo: headerView.bottomAnchor),
      viewController.view.rightAnchor.constraint(equalTo: contentView.rightAnchor),
      viewController.view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
      viewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      ])
    
  }
}

