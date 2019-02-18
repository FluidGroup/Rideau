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

class ViewController: UIViewController {

  let cabinetView = RideauView(frame: .zero) { (config) in
    config.snapPoints = [.pointsFromBottom(120), .fraction(0.4), .fraction(0.8), .fraction(1)]
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    view.addSubview(cabinetView)

    cabinetView.frame = view.bounds
    cabinetView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    let menu = MenuView()
    
    cabinetView.containerView.set(bodyView: menu, options: .strechDependsVisibleArea)
    cabinetView.isTrackingKeyboard = false
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print("viewDidAppear")
  }

  @IBAction func didTapShowButton(_ sender: Any) {
    cabinetView.move(to: .fraction(1), animated: true, completion: {})
  }

  @IBAction func didTapShowModalButton(_ sender: Any) {
    
    let target = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TargetViewController") as! TargetViewController
    
    let controller = RideauViewController(
      bodyViewController: target,
      configuration: {
        var config = RideauView.Configuration()
        config.snapPoints = [.hidden, .autoPointsFromBottom, .fraction(1)]
        return config
    }(),
      initialSnapPoint: .autoPointsFromBottom
    )
    
    present(controller, animated: true, completion: nil)
    
  }
  
  @IBAction func didTapShowMenuButton(_ sender: Any) {
    
    let target = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HasScrollableContentViewController") as! HasScrollableContentViewController
    
    let controller = RideauViewController(
      bodyViewController: target,
      configuration: {
        var config = RideauView.Configuration()
        config.snapPoints = [.hidden, .autoPointsFromBottom, .fraction(0.8)]
        return config
    }(),
      initialSnapPoint: .autoPointsFromBottom
    )
    
    controller.rideauView.delegate = target
    
    present(controller, animated: true, completion: nil)
  }
  
  @IBAction func didTapShowFullScreen(_ sender: Any) {
    
    let target = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HasScrollableContentViewController") as! HasScrollableContentViewController
    
    let controller = RideauViewController(
      bodyViewController: target,
      configuration: {
        var config = RideauView.Configuration()
        config.snapPoints = [.hidden, .autoPointsFromBottom, .fraction(1)]
        config.topMargin = .fromTop(0)
        return config
    }(),
      initialSnapPoint: .autoPointsFromBottom
    )
    
    controller.rideauView.delegate = target
    
    present(controller, animated: true, completion: nil)
    
  }
  
}

extension ViewController {

  final class MenuView : UIView {
    
    let titleView = UIView()

    let contentView = UIView()

    let container = UIView()
    
    let button = UIButton(type: .system)

    init() {
      super.init(frame: .zero)

      container.translatesAutoresizingMaskIntoConstraints = false
      addSubview(container)
      
      NSLayoutConstraint.activate([
        container.topAnchor.constraint(equalTo: topAnchor),
        container.rightAnchor.constraint(equalTo: rightAnchor),
        container.bottomAnchor.constraint(equalTo: bottomAnchor),
        container.leftAnchor.constraint(equalTo: leftAnchor),
        ])
      
      container.addSubview(titleView)
      container.addSubview(contentView)
      container.addSubview(button)
      
      button.setTitle("Hello", for: .normal)

      titleView.translatesAutoresizingMaskIntoConstraints = false
      contentView.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        
        titleView.topAnchor.constraint(equalTo: topAnchor),
        titleView.rightAnchor.constraint(equalTo: rightAnchor),
        titleView.leftAnchor.constraint(equalTo: leftAnchor),
        titleView.heightAnchor.constraint(equalToConstant: 55),
        
        contentView.topAnchor.constraint(equalTo: titleView.bottomAnchor),
        contentView.rightAnchor.constraint(equalTo: rightAnchor),
        contentView.leftAnchor.constraint(equalTo: leftAnchor),
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

      titleView.backgroundColor = UIColor(white: 0.2, alpha: 1)
      contentView.backgroundColor = UIColor(white: 0.3, alpha: 1)
      container.backgroundColor = UIColor(white: 0.5, alpha: 1)

      container.layer.cornerRadius = 8
      if #available(iOS 11.0, *) {
        container.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
      } else {
        // Fallback on earlier versions
      }
      container.layer.masksToBounds = true

      layer.cornerRadius = 8
      layer.shadowColor = UIColor(white: 0, alpha: 0.2).cgColor
      layer.shadowOpacity = 1
      layer.shadowOffset = CGSize(width: 0, height: 0)
      layer.shadowRadius = 4

    }

    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
}

