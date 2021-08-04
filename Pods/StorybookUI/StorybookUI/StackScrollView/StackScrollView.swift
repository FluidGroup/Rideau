// StackScrollView.swift
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

final class StackScrollView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  private enum LayoutKeys {
    static let top = "me.muukii.StackScrollView.top"
    static let right = "me.muukii.StackScrollView.right"
    static let left = "me.muukii.StackScrollView.left"
    static let bottom = "me.muukii.StackScrollView.bottom"
    static let width = "me.muukii.StackScrollView.width"
  }
  
  private static func defaultLayout() -> UICollectionViewFlowLayout {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    layout.sectionInset = .zero
    return layout
  }
  
  @available(*, unavailable)
  override var dataSource: UICollectionViewDataSource? {
    didSet {
    }
  }
  
  @available(*, unavailable)
  override var delegate: UICollectionViewDelegate? {
    didSet {
    }
  }
  
  // MARK: - Initializers
  
  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)
    setup()
  }
  
  convenience init(frame: CGRect) {
    self.init(frame: frame, collectionViewLayout: StackScrollView.defaultLayout())
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  private(set) var views: [UIView] = []

  private func setup() {
    
    backgroundColor = .white
    
    alwaysBounceVertical = true
    delaysContentTouches = false
    keyboardDismissMode = .interactive
    backgroundColor = .clear
    
    super.delegate = self
    super.dataSource = self

    register(Cell.self, forCellWithReuseIdentifier: "Cell")
    isPrefetchingEnabled = false

  }
  
  override func touchesShouldCancel(in view: UIView) -> Bool {
    return true
  }

  func append(view: UIView) {
    
    views.append(view)
    reloadData()
  }  
  
  func append(views _views: [UIView]) {
    
    views += _views
    reloadData()
  }
  
  @available(*, unavailable, message: "Unimplemented")
  func append(lazy: @escaping () -> UIView) {
    
  }

  func scroll(to view: UIView, animated: Bool) {
    
    let targetRect = view.convert(view.bounds, to: self)
    scrollRectToVisible(targetRect, animated: true)
  }
  
  func scroll(to view: UIView, at position: UICollectionView.ScrollPosition, animated: Bool) {
    if let index = views.firstIndex(of: view) {
      scrollToItem(at: IndexPath(item: index, section: 0), at: position, animated: animated)
    }
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return views.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let view = views[indexPath.item]

    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    
    if view.superview == cell.contentView {
      return cell
    } else {
      cell.contentView.subviews.forEach {
        $0.removeFromSuperview()
      }
    }
    
    view.translatesAutoresizingMaskIntoConstraints = false
    cell.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    cell.contentView.addSubview(view)

    let top = view.topAnchor.constraint(equalTo: cell.contentView.topAnchor)
    let right = view.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor)
    let bottom = view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
    let left = view.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor)

    top.identifier = LayoutKeys.top
    right.identifier = LayoutKeys.right
    bottom.identifier = LayoutKeys.bottom
    left.identifier = LayoutKeys.left

    NSLayoutConstraint.activate([
      top,
      right,
      bottom,
      left,
    ])

    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let view = views[indexPath.item]
    
    let width: NSLayoutConstraint = {

      guard let c = view.constraints.filter({ $0.identifier == LayoutKeys.width }).first else {
        let width = view.widthAnchor.constraint(equalToConstant: collectionView.bounds.width)
        width.identifier = LayoutKeys.width
        width.isActive = true
        return width
      }

      return c
    }()

    width.constant = collectionView.bounds.width

    let size = view.superview?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

    return size
  }
  
  func updateLayout(animated: Bool) {
    
    if animated {
      UIView.animate(
        withDuration: 0.5,
        delay: 0,
        usingSpringWithDamping: 1,
        initialSpringVelocity: 0,
        options: [
          .beginFromCurrentState,
          .allowUserInteraction,
          .overrideInheritedCurve,
          .overrideInheritedOptions,
          .overrideInheritedDuration
        ],
        animations: {
          self.performBatchUpdates(nil, completion: nil)
          self.layoutIfNeeded()
      }) { (finish) in
        
      }
    } else {
      UIView.performWithoutAnimation {
        self.performBatchUpdates(nil, completion: nil)
        self.layoutIfNeeded()
      }
    }
  }
  
  final class Cell: UICollectionViewCell {
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
      return layoutAttributes
    }
  }
}
