# 🎪 Rideau

Rideau is a drawer UI similar to what Apple's apps use. (e.g Maps, Shortcuts)

![](./sample1.gif)
![](./sample2.gif)

## Overview

- 💎 Supports multiple snap points (e.g. most hidden, half visible, full visible, and we can add more snap points.)
- 💎 Supports Animations alongside moving (e.g. dimming background color)
- 💎 Supports handling scrolling of scrollview inside RideauView
- 💎 Supports resizing based on intrinsic content size of view that RideauView has
- ✅ Interactive Animations come from UIViewPropertyAnimator, with this it's actual interruptible animation and no glitches. (it can't get from UIView.animate)

RideauView allows for flexible snap points.
`Snap points` pertains to specified offsets where the draggable view "snaps to" when the dragging has ended.
There are usually 2 or 3 snap points.

---

Objects we will commonly use:

- RideauView
- RideauViewController
- RideauSnapPoint

`RideauView` is the core object in this library.
We typically add our own view to RideauView.

`RideauViewController` contains a `RideauView`.
It allows us to present the RideauView as modal dialog.

`RideauSnapPoint` defines where the content view stops.

## 🔶 Requirements

iOS 10.0+
Xcode 13+
Swift 5.5+

## 📱 Features

- [x] Multiple snap-point
- [x] Smooth integration with dragging and UIScrollView's scrolling.
- [x] Tracking UIScrollView automatically
- [x] Set UIScrollView to track manually
- [x] Use UIViewPropertyAnimator between snap-points.

## 👨🏻‍💻 Usage

### Present inline

```swift
let rideauView = RideauView(
  frame: .zero,
  configuration: .init { config in
    config.snapPoints = [.autoPointsFromBottom, .fraction(0.6), .fraction(1)]
  }
)

let someView: UIView = ...

rideauView.containerView.set(
  bodyView: someView,
  resizingOption: .resizeToVisibleArea
)
```

### Present with Modal Presentation

```swift
let targetViewController: YourViewController = ...

let controller = RideauViewController(
  bodyViewController: targetViewController,
  configuration: .init { config in
    config.snapPoints = [.autoPointsFromBottom, .fraction(1)]
  },
  initialSnapPoint: .autoPointsFromBottom,
  resizingOption: .resizeToVisibleArea
)

present(controller, animated: true, completion: nil)
```

### Multiple SnapPoints

We can define snap-point with `RideauSnapPoint`.

```swift
public enum RideauSnapPoint: Hashable {

  case fraction(CGFloat)
  case pointsFromTop(CGFloat)
  case pointsFromBottom(CGFloat)
  case autoPointsFromBottom

  case hidden

  public static let full: RideauSnapPoint = .fraction(1)
}
```

```swift
config.snapPoints = [.pointsFromBottom(200), .fraction(0.5), .fraction(0.8), .fraction(1)]
```

### ⚙️ Details

`RideauContentContainerView` has two ways of resizing the content view that is added.

* `RideauContentContainerView.ResizingOption`
  * `noResize`
  * `resizeToVisibleArea`

```swift
public final class RideauContentContainerView: UIView {
  public func set(bodyView: UIView, resizingOption: ResizingOption)
}
```

### 🔌 Components

Rideau provides the following components that may help us.

#### RideauMaskedCornerRoundedViewController

A Container view controller that implements masked rounded corner interface and has some options.

- [ ] More customizable

```swift
let targetViewController: YourViewController = ...

let controller = RideauViewController(
  bodyViewController: RideauMaskedCornerRoundedViewController(viewController: targetViewController),
  configuration: .init { config in
    config.snapPoints = [.autoPointsFromBottom, .fraction(1)]
  },
  initialSnapPoint: .autoPointsFromBottom,
  resizingOption: .resizeToVisibleArea
)
```

#### RideauMaskedCornerRoundedView

- [ ] More customizable

![](round.png)

#### RideauThumbView

- [ ] More customizable

![](thumb.png)

## Installation

### CocoaPods

Rideau is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Rideau'
```

### Carthage

For [Carthage](https://github.com/Carthage/Carthage), add the following to your `Cartfile`:

```ogdl
github "muukii/Rideau"
```

### What's using Rideau

- [Pairs](https://itunes.apple.com/tw/app/id825433065)

## Author

- [Muukii(Hiroshi Kimura)](https://github.com/muukii)

## Contributors

- [John Estropia](https://twitter.com/JohnEstropia)

## SwiftUI Edition

https://github.com/nerdsupremacist/Snap

## License

Rideau is released under the MIT license.
