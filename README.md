# Rideau

Rideau is a UI like a drawer that is used on applications Apple makes.
(e.g Maps, Shortcuts)

> ⚠️ Rideau is still in Beta. API may have breaking changes in the future.

<img src="./sample1.gif" />
<img src="./sample2.gif" />

## Overview

RideauView provides a feature of flexible snap points.<br>
`snap points` means where draggable view stops when dragging ended.<br>
Basically, number of snap points are 2 or 3.

---

Main objects what we usually use are followings.

- RideauView
- RideauViewController
- RideauSnapPoint

`RideauView` is the core object on this library.
We add a view to RideauView

`RideauViewController` has `RideauView`.
It allows us to present RideauView as modal presentation.

`RideauSnapPoint` defines where the content view stops.

## Requirements

iOS 10.0+
Xcode 10.1+
Swift 4.2+

## Usage

### Present as inline

// TODO

### Present with Modal Presentation

// TODO

## Installation

### CocoaPods

Pixel is available through [CocoaPods](https://cocoapods.org). To install
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

[Muukii(Hiroshi Kimura)](https://github.com/muukii)

## Contributors

[John Estropia](https://twitter.com/JohnEstropia)
[Aymen](https://twitter.com/aymenworks)

## License

Rideau is released under the MIT license.
