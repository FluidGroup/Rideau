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

open class StackScrollView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
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
  open override var dataSource: UICollectionViewDataSource? {
    didSet {
    }
  }
  
  @available(*, unavailable)
  open override var delegate: UICollectionViewDelegate? {
    didSet {
    }
  }
  
  // MARK: - Initializers
  
  public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)
    setup()
  }
  
  public convenience init(frame: CGRect) {
    self.init(frame: frame, collectionViewLayout: StackScrollView.defaultLayout())
    setup()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  private(set) public var views: [UIView] = []
  
  private func identifier(_ v: UIView) -> String {
    return v.hashValue.description
  }
  
  private func setup() {
    
    backgroundColor = .white
    
    alwaysBounceVertical = true
    delaysContentTouches = false
    keyboardDismissMode = .interactive
    backgroundColor = .clear
    
    super.delegate = self
    super.dataSource = self
  }
  
  open override func touchesShouldCancel(in view: UIView) -> Bool {
    return true
  }

  open func append(view: UIView) {
    
    views.append(view)
    register(Cell.self, forCellWithReuseIdentifier: identifier(view))
    reloadData()
  }  
  
  open func append(views _views: [UIView]) {
    
    views += _views
    _views.forEach { view in
      register(Cell.self, forCellWithReuseIdentifier: identifier(view))
    }
    reloadData()
  }
  
  @available(*, unavailable, message: "Unimplemented")
  func append(lazy: @escaping () -> UIView) {
    
  }

  open func insert(views _views: [UIView], at index: Int, animated: Bool) {

    var _views = _views
    _views.removeAll(where: views.contains(_:))
    views.insert(contentsOf: _views, at: index)
    _views.forEach { view in
      register(Cell.self, forCellWithReuseIdentifier: identifier(view))
    }
    let batchUpdates: () -> Void = {
      self.performBatchUpdates({
        self.insertItems(at: (index ..< index.advanced(by: _views.count)).map({ IndexPath(item: $0, section: 0) }))
      }, completion: nil)
    }
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
        animations: batchUpdates,
        completion: nil)

    } else {
      UIView.performWithoutAnimation(batchUpdates)
    }
  }

  open func insert(views _views: [UIView], before view: UIView, animated: Bool) {

    guard let index = views.firstIndex(of: view) else {
      return
    }
    insert(views: _views, at: index, animated: animated)
  }

  open func insert(views _views: [UIView], after view: UIView, animated: Bool) {

    guard let index = views.firstIndex(of: view)?.advanced(by: 1) else {
      return
    }
    insert(views: _views, at: index, animated: animated)
  }
  
  open func remove(view: UIView, animated: Bool) {
    
    if let index = views.firstIndex(of: view) {
      views.remove(at: index)
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
            self.performBatchUpdates({
              self.deleteItems(at: [IndexPath(item: index, section: 0)])
            }, completion: nil)
        }) { (finish) in
          
        }
        
      } else {
        UIView.performWithoutAnimation {
          performBatchUpdates({
            self.deleteItems(at: [IndexPath(item: index, section: 0)])
          }, completion: nil)
        }
      }
    }
  }
  
  open func remove(views: [UIView], animated: Bool) {

    var indicesForRemove: [Int] = []

    for view in views {
      if let index = self.views.firstIndex(of: view) {
        indicesForRemove.append(index)
      }
    }

    // It seems that the layout is not updated properly unless the order is aligned.
    indicesForRemove.sort(by: >)

    for index in indicesForRemove {
      self.views.remove(at: index)
    }

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
          self.performBatchUpdates({
            self.deleteItems(at: indicesForRemove.map { IndexPath.init(item: $0, section: 0) })
          }, completion: nil)
        })
    } else {
      UIView.performWithoutAnimation {
        performBatchUpdates({
          self.deleteItems(at: indicesForRemove.map { IndexPath.init(item: $0, section: 0) })
        }, completion: nil)
      }
    }
  }

  open func scroll(to view: UIView, animated: Bool) {
    
    let targetRect = view.convert(view.bounds, to: self)
    scrollRectToVisible(targetRect, animated: true)
  }
  
  open func scroll(to view: UIView, at position: UICollectionView.ScrollPosition, animated: Bool) {
    if let index = views.firstIndex(of: view) {
      scrollToItem(at: IndexPath(item: index, section: 0), at: position, animated: animated)
    }
  }
  
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return views.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let view = views[indexPath.item]
    let _identifier = identifier(view)
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: _identifier, for: indexPath)
    
    if view.superview == cell.contentView {
      return cell
    }
    
    precondition(cell.contentView.subviews.isEmpty)

    if view is ManualLayoutStackCellType {

      cell.contentView.addSubview(view)
      
    } else {

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
    }
    
    return cell
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let view = views[indexPath.item]

    if let view = view as? ManualLayoutStackCellType {

      return view.size(maxWidth: collectionView.bounds.width, maxHeight: nil)

    } else {

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
  }
  
  public func updateLayout(animated: Bool) {
    
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
