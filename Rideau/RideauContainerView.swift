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

/// Main view
/// This view will be translated with user interaction.
/// Frame.size.height will be set maximum SnapPoint.
/// plus, Frame.size will not change.
public final class RideauContainerView : UIView {
  
  public enum SizingOption {
    case strechDependsVisibleArea
    case noStretch
  }
  
  public let accessibleAreaLayoutGuide: UILayoutGuide = .init()
  public let visibleAreaLayoutGuide: UILayoutGuide = .init()
  
  public weak var currentBodyView: UIView?
  private var previousSizeOfBodyView: CGSize?
  
  var didChangeContent: () -> Void = {}
  
  // MARK: - Initializers
  
  init() {
    
    super.init(frame: .zero)
    
    accessibleAreaLayoutGuide.identifier = "muukii.Rideau.accessibleAreaLayoutGuide"
    visibleAreaLayoutGuide.identifier = "muukii.Rideau.visibleAreaLayoutGuide"
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Functions
  
  public func requestUpdateLayout() {
    didChangeContent()
  }
  
  @available(*, unavailable, message: "Don't add view directory, use set(bodyView: options:)")
  public override func addSubview(_ view: UIView) {
    assertionFailure("Don't add view directory, use set(bodyView: options:)")
    super.addSubview(view)
  }
  
  public func set(bodyView: UIView, options: SizingOption) {
    
    currentBodyView?.removeFromSuperview()
    super.addSubview(bodyView)
    currentBodyView = bodyView
    bodyView.translatesAutoresizingMaskIntoConstraints = false
    
    switch options {
    case .noStretch:
      
      NSLayoutConstraint.activate([
        bodyView.topAnchor.constraint(equalTo: topAnchor),
        bodyView.rightAnchor.constraint(equalTo: rightAnchor),
        bodyView.leftAnchor.constraint(equalTo: leftAnchor),
        bodyView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
      
    case .strechDependsVisibleArea:
      
      NSLayoutConstraint.activate([
        bodyView.topAnchor.constraint(equalTo: visibleAreaLayoutGuide.topAnchor),
        bodyView.rightAnchor.constraint(equalTo: visibleAreaLayoutGuide.rightAnchor),
        bodyView.leftAnchor.constraint(equalTo: visibleAreaLayoutGuide.leftAnchor),
        bodyView.bottomAnchor.constraint(greaterThanOrEqualTo: visibleAreaLayoutGuide.bottomAnchor),
        bodyView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor),
        {
          let c = bodyView.bottomAnchor.constraint(equalTo: visibleAreaLayoutGuide.bottomAnchor)
          c.priority = .fittingSizeLevel
          return c
        }()
        ])
      
    }
    
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    if previousSizeOfBodyView != currentBodyView?.bounds.size {
      previousSizeOfBodyView = currentBodyView?.bounds.size
      didChangeContent()
    }
  }
  
  func set(owner: RideauInternalView) {
    
    addLayoutGuide(accessibleAreaLayoutGuide)
    addLayoutGuide(visibleAreaLayoutGuide)
    
    let priority = UILayoutPriority.defaultLow

    
    visible: do {
      
      NSLayoutConstraint.activate([
        {
          let c = visibleAreaLayoutGuide.topAnchor.constraint(equalTo: topAnchor)
          c.priority = priority
          return c
        }(),
        visibleAreaLayoutGuide.rightAnchor.constraint(equalTo: rightAnchor),
        visibleAreaLayoutGuide.leftAnchor.constraint(equalTo: leftAnchor),
        {
          let c = visibleAreaLayoutGuide.bottomAnchor.constraint(equalTo: owner.bottomAnchor)
          c.priority = priority
          return c
        }(),
        ]
      )
    }
    
    accessible: do {
      let right = accessibleAreaLayoutGuide.rightAnchor.constraint(equalTo: rightAnchor)
      let left = accessibleAreaLayoutGuide.leftAnchor.constraint(equalTo: leftAnchor)
      
      let top = accessibleAreaLayoutGuide.topAnchor.constraint(equalTo: topAnchor)
      top.priority = priority
      
      let bottom: NSLayoutConstraint
      if #available(iOS 11.0, *) {
        bottom = accessibleAreaLayoutGuide.bottomAnchor.constraint(equalTo: owner.safeAreaLayoutGuide.bottomAnchor)
      } else {
        bottom = accessibleAreaLayoutGuide.bottomAnchor.constraint(equalTo: owner.bottomAnchor)
      }
      bottom.priority = priority
      
      NSLayoutConstraint.activate([
        top, right, left, bottom
        ])
    }
    
  }
}
