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

import Rideau

final class ViewController: UIViewController {

  @IBOutlet weak var box1: UIView!
  
  @IBOutlet weak var box2: UIView!
  
  private let rideauView = RideauView(frame: .zero) { (config) in
    config.snapPoints = [.autoPointsFromBottom, .fraction(0.7), .fraction(1)]
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    view.addSubview(rideauView)

    rideauView.frame = view.bounds
    rideauView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    let controller = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainMenuViewController") as! MainMenuViewController

    let container = RideauMaskedCornerRoundedViewController()
    container.isThumbVisible = true
    container.set(viewController: controller)
    container.willMove(toParent: self)
    addChild(container)
    
    rideauView.containerView.set(bodyView: container.view, resizingOption: .resizeToVisibleArea)
    rideauView.isTrackingKeyboard = false
    rideauView.delegate = self
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print("viewDidAppear")
  }


  
}

extension ViewController : RideauViewDelegate {
  func rideauView(_ rideauView: RideauView, alongsideAnimatorsFor range: ResolvedSnapPointRange) -> [UIViewPropertyAnimator] {
    
    switch (range.start.source, range.end.source) {
    case (.fraction(1), .fraction(0.7)):
      
      let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
        self.box1.alpha = 0.3
      }
      
      return [animator]
      
    case (.fraction(0.7), .autoPointsFromBottom):
      
      let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
        self.box2.alpha = 0.3
      }
      
      return [animator]
      
    default:
      return []
    }
  }
  
  func rideauView(_ rideauView: RideauView, willMoveTo snapPoint: RideauSnapPoint) {

  }
  
  func rideauView(_ rideauView: RideauView, didMoveTo snapPoint: RideauSnapPoint) {

  }
  
  
}
