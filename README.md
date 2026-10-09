# 🎪 Rideau

Rideau is a drawer UI similar to what Apple's apps use. (e.g Maps, Shortcuts)

> 🚀 Rideau is in release candidate!

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
Xcode 10.1+
Swift 4.2+

## 📱 Features

- [x] Multiple snap-point
- [x] Smooth integration with dragging and UIScrollView's scrolling.
- [x] Tracking UIScrollView automatically
- [x] Set UIScrollView to track manually
- [x] Use UIViewPropertyAnimator between snap-points.

## 👨🏻‍💻 Usage

### Present inline

```swift
let rideauView = RideauView(frame: .zero) { (config) in
  config.snapPoints = [.autoPointsFromBottom, .fraction(0.6), .fraction(1)]
}
  
let someView = ...

rideauView.containerView.set(bodyView: container.view, options: .strechDependsVisibleArea)
```

### Present with Modal Presentation

```swift

let targetViewController: YourViewController = ...

let controller = RideauViewController(
  bodyViewController: targetViewController,
  configuration: {
    var config = RideauView.Configuration()
    config.snapPoints = [.autoPointsFromBottom, .fraction(1)]
    return config
}(),
  initialSnapPoint: .autoPointsFromBottom
)

present(controller, animated: true, completion: nil)
```

### Multiple SnapPoints

We can define snap-point with `RideauSnapPoint`.

```swift
public enum RideauSnapPoint : Hashable {
  
  case fraction(CGFloat)
  case pointsFromTop(CGFloat)
  case pointsFromBottom(CGFloat)
  case autoPointsFromBottom
}
```

```swift
config.snapPoints = [.pointsFromBottom(200), .fraction(0.5), .fraction(0.8), .fraction(1)]
```

### Adaptive width

Keep the sheet bottom-aligned while limiting its width on larger windows:

```swift
let configuration = RideauView.Configuration {
  $0.snapPoints = [.hidden, .autoPointsFromBottom, .fraction(1)]
  $0.horizontalLayout = .adaptive(maximumWidth: 640)
}
```

The sheet is centered within its available region, with an 8-point inset on
either side. Pass `edgeInset` to customize that spacing. The backdrop still
covers the entire host. The default, `.fullWidth`, preserves existing layouts.

On iOS 27.1 and later, when built with Xcode 27.1 or later, an active vertical
division moves the sheet into the leading region. The system's reserved-region
margins are respected. Horizontal divisions do not change its placement.
Earlier systems still support the width limit and centering.

Resizing keeps the existing content and selected snap point.
`.autoPointsFromBottom` measures the content at the resolved sheet width.
Use `containerView.accessibleAreaLayoutGuide` for controls that should stay
within the sheet's safe area.

Run the `RideauDemo2` scheme and open **Adaptive width / Scrollable sheet** or
**Adaptive width / Self-sizing sheet** to try opening, folding, and rotating
iPhone Duo.
Open `Package.swift` in Xcode and test the package's `Rideau` scheme on an iOS
Simulator to run the layout and interaction tests.

### Demo catalog

`RideauDemo2` uses Storybook 3.2.2 and requires iOS 17 or later and a Swift 6.3
or later toolchain. Its 27 scenarios are declared as named `#Preview`s in
`RideauDemo2/Book.swift`, so the same declarations work in Xcode Canvas and
the in-app catalog.

**Adaptive width / Safe area** shows the content's safe area in green and the
excluded region in orange, with live window and content right-inset readings.
Its controls follow the content's `safeAreaLayoutGuide`; resize the sheet or
fold the device to see the values change. This example is embedded directly
in the catalog viewport so an outer system sheet does not affect measurements.
Modal backdrops cover the full window while the sheet keeps its own width
limit, including when the window resizes.

The library keeps the deployment targets from 2.4.2: iOS 10 for Swift Package
Manager and iOS 14 for the Xcode framework target. Only `RideauDemo2` requires
iOS 17. When building with an SDK that no longer supports iOS 14, set
`IPHONEOS_DEPLOYMENT_TARGET=17.0` for the local demo build.

The app also accepts Storybook's direct-launch arguments. For example, pass
these arguments to open one exact scenario:

```text
--storybook "Adaptive width / Self-sizing sheet" --storybook-file RideauDemo2/Book.swift
```

### ⚙️ Details

RideauContainerView has two ways of resizing content view which is added.

* `RideauContainerView.ResizingOption`
  * noResize
  * resizeToVisibleArea
  
```swift
final class RideauContainerView : UIView {
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
let toDisplayViewController = RideauMaskedCornerRoundedViewController(viewController: targetViewController)

let controller = RideauViewController(
  bodyViewController: RideauMaskedCornerRoundedViewController(viewController: target),
  ...
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
