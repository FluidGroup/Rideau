# StackScrollView

[![CI Status](http://img.shields.io/travis/muukii/StackScrollView.svg?style=flat)](https://travis-ci.org/muukii/StackScrollView)
[![Version](https://img.shields.io/cocoapods/v/StackScrollView.svg?style=flat)](http://cocoapods.org/pods/StackScrollView)
[![License](https://img.shields.io/cocoapods/l/StackScrollView.svg?style=flat)](http://cocoapods.org/pods/StackScrollView)
[![Platform](https://img.shields.io/cocoapods/p/StackScrollView.svg?style=flat)](http://cocoapods.org/pods/StackScrollView)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

<img width=320 src="Resources/shot.png"><img width=320 src="Resources/sample.gif">

⚠️ This sample is using demo-components.
StackScrollView does not have default-components.
StackScrollView is like UIStackView.
So, we need to create the components we need.

## What is this?

StackScrollView builds form UI easily.

StackScrollView includes UICollectionView.
UICollectionView calculates size of view by AutoLayout, then that display.
(Use `systemLayoutSizeFitting`)

- We call `StackCell` instead of `Cell` on StackScrollView.
- We no longer need to consider reusing Cells.
- `StackCell` requires constraint based layout.

## Usage

### Basic usage

```swift
let stack = StackScrollView()

stack.append(view: ...)

stack.remove(view: ..., animated: true)
```

### APIs

#### StackScrollView

```swift
func append(view: UIView)
func remove(view: UIView, animated: Bool)
func scroll(to view: UIView, at position: UICollectionViewScrollPosition, animated: Bool)
```

#### StackCellType

StackScrollView does not required StackCellType.
if `StackCell` has `StackCellType`, be easy that control StackCell.

```swift
func scrollToSelf(animated: Bool)
func scrollToSelf(at position: UICollectionViewScrollPosition, animated: Bool)
func updateLayout(animated: Bool)
func remove()
```

*Demo has included this APIs usage.*

### Create CustomCell from Code

*We have to set constraints completely.*

```swift
final class LabelStackCell: UIView {
  
  private let label = UILabel()
  
  init(title: String) {
    super.init(frame: .zero)
    
    addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    
    label.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 8).isActive = true
    label.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: 8).isActive = true
    label.rightAnchor.constraint(equalTo: rightAnchor, constant: 8).isActive = true
    label.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
    label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
    
    label.font = UIFont.preferredFont(forTextStyle: .body)
    label.text = title
  }
}
```

```swift
let stack = StackScrollView()
stack.append(view: LabelStackCell(title: "Label"))
```

### Create CustomCell from XIB

We can use UIView from XIB.

This framework has `NibLoader<T: UIView>`.
It might be useful for you.

### Create everything

You can create any Cell.
Please, check `StackScrollView-Demo`

### ManualLayout

You can create Cell with ManualLayout.

If you use ManualLayout, the Cell have to use `ManualLayoutStackCellType`.
Then, return self-size based on maximum size in `size(maxWidth:maxHeight)`

## Author

muukii, muukii.app@gmail.com

## License

StackScrollView is available under the MIT license. See the LICENSE file for more info.
