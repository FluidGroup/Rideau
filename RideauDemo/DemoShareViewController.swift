//
//  DemoShareViewController.swift
//  RideauDemo
//
//  Created by muukii on 2019/08/31.
//  Copyright © 2019 Hiroshi Kimura. All rights reserved.
//

import UIKit

import StackScrollView
import EasyPeasy

final class DemoShareViewController: UIViewController {
  
  let stackScrollView: StackScrollView = .init()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    view.addSubview(stackScrollView)
    stackScrollView.easy.layout(Edges())
    
    stackScrollView.append(
      view: HorizontalStackCell(
        views: [
          SquareItemView(),
          SquareItemView(),
          SquareItemView(),
          SquareItemView(),
          SquareItemView(),
          SquareItemView(),
          SquareItemView(),
          SquareItemView(),
          SquareItemView(),
        ]
      )
    )
    
    stackScrollView.append(
      view: HorizontalStackCell(
        views: [
          SquareItemView(),
          SquareItemView(),         
        ]
      )
    )
    
    view.easy.layout(Height(>=120))
  }
}

extension DemoShareViewController {
  
  final class SquareItemView: UIView {
    
    init() {
      super.init(frame: .zero)
      
      backgroundColor = .init(white: 0.8, alpha: 1)
      layer.cornerRadius = 8

      easy.layout(Size(64))
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    
  }
  
  final class HorizontalStackCell: UIView {
    
    init(views: [UIView]) {
      super.init(frame: .zero)
      
      let stackView = UIStackView(arrangedSubviews: views)
      stackView.spacing = 16
      stackView.axis = .horizontal
      
      let scrollView = UIScrollView()
      scrollView.alwaysBounceVertical = false
      scrollView.showsHorizontalScrollIndicator = false
      scrollView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
      
      scrollView.addSubview(stackView)
      
      stackView.easy.layout([
        Edges(),
        Height().like(scrollView, .height),
      ])
      
      addSubview(scrollView)
      scrollView.easy.layout([
        Top(16),
        Left(),
        Right(),
        Bottom(16),
      ])
      
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
  }
  
}
