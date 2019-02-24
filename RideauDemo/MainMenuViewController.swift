//
//  MainMenuViewController.swift
//  RideauDemo
//
//  Created by muukii on 2019/02/24.
//  Copyright © 2019 muukii. All rights reserved.
//

import UIKit

import Rideau

final class MainMenuViewController : UIViewController {
  
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
      bodyViewController: RideauMaskedCornerRoundedViewController(viewController: target),
      configuration: {
        var config = RideauView.Configuration()
        config.snapPoints = [.hidden, .autoPointsFromBottom, .fraction(0.6), .fraction(1)]
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
