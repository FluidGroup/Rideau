[![Swift 5.2](https://img.shields.io/badge/swift-5.2-ED523F.svg?style=flat)](https://swift.org/download/)
![cocoapods](https://img.shields.io/cocoapods/v/StorybookKit)
![cocoapods](https://img.shields.io/cocoapods/v/StorybookUI)

# Storybook for iOS

Storybook for iOS is a library to gains the speed of UI development.<br>
It brings us to preview the component independently each state that UI can display.

This library enables us to develop the UI without many times to rebuild in a big application and we could build them fully without missing an exception case.

<sub>✨This library is inspired by [Storybook](https://storybook.js.org/) for Web application development.</sub>
  
  <p>
<img width=250 src="https://user-images.githubusercontent.com/1888355/82451356-d7183700-9ae8-11ea-89b2-0012ac946e1c.gif" />
<img width=250 src="https://user-images.githubusercontent.com/1888355/82452853-c072df80-9aea-11ea-9d83-e41077c61b28.png" />
  <img width=250 src="https://user-images.githubusercontent.com/1888355/82452872-c5d02a00-9aea-11ea-9866-f57c30ff1fbe.gif" />
  </p>

## Features

- Previewing any component each state and dynamically updates
- Presenting any view controller
- Creating nested pages infinitely
- Mark the components up with organized typography
- Declarative syntax like SwiftUI

## Basic Usage

*Setting up your book**

Use this example component `MyComponent` for demo.
It's just a box that filled with purple color.

```swift
public final class MyComponent: UIView {

  public override func layoutSubviews() {
    super.layoutSubviews()

    backgroundColor = .systemPurple
  }

  public override var intrinsicContentSize: CGSize {
    .init(width: 60, height: 60)
  }
}
```

`Book` indicates a root of Storybook.<br>
Book can have a name describes itself, and we can declare the contents inside trailing closure.

💡You need to import `StorybookKit` module.<br>
This module only provides the symbol to describe a book.

```swift
import StorybookKit

let myBook = Book(title: "MyBook") {
  ...
}
```

For now we put a preview of `MyComponent` with `BookPreview`.

```swift
let myBook = Book(title: "MyBook") {
  BookPreview {
    let myComponent = MyComponent()
    return MyComponent()
  }
}
```

To display this book, present StorybookViewController on any view controller.

💡You need to import `StorybookUI` module.<br>
This module provides the feature to display the book.

```swift
import StorybookUI

let controller = StorybookViewController(book: myBook) {
  $0.dismiss(animated: true, completion: nil)
}

present(controller, animated: true, completion: nil)
```

<img width=320 src="https://user-images.githubusercontent.com/1888355/82445841-7ab11980-9ae0-11ea-91f0-3ff2974d25cc.png" />


**Adding the name of the component**

`BookPreview` can have the name label with like this.

```swift
BookPreview {
  let component = MyComponent()
  return component
}
.title("MyComponent")
```

<img width=320 src="https://user-images.githubusercontent.com/1888355/82446390-88b36a00-9ae1-11ea-9e3f-a6bc66231f01.png" />

**List the state of the component**

A UI component would have several states depends on something.
We can list that components each state with following.

```swift
let myBook = Book(title: "MyBook") {
  BookPreview {
    let button = UISwitch()
    button.isOn = true
    return button
  }
  .title("UISwitch on")

  BookPreview {
    let button = UISwitch()
    button.isOn = false
    return button
  }
  .title("UISwitch off")
}
```

<img width=320 src="https://user-images.githubusercontent.com/1888355/82446756-34f55080-9ae2-11ea-8aff-31acf5993638.png" />

Of course, you can interact with these components.

**Update a state of the components dynamically**

UI Components should have a responsibility that updates themselves correctly with the new state.<br>
For example, resizing itself according to the content.

In order to check this behavior, `BookPreview` can have the button to update something of the component.

```swift
BookPreview<UILabel> {
  let label = UILabel()
  label.text = "Initial Value"
  return label
}
.addButton("short text") { (label) in
  label.text = "Hello"
}
.addButton("long text") { (label) in
  label.text = "Hello, Hello,"
}
```

<img width=320 src="https://user-images.githubusercontent.com/1888355/82447850-d16c2280-9ae3-11ea-9186-bb1c1509a94d.gif" />

**Present ViewController**

When we need to check a popup, we use `BookPresent` declaration.

```swift
BookPresent(title: "Pop") {
  let alert = UIAlertController(
    title: "Hi Storybook",
    message: "As like this, you can present any view controller to check the behavior.",
    preferredStyle: .alert
  )
  alert.addAction(.init(title: "Got it", style: .default, handler: { _ in }))
  return alert
}

BookPresent(title: "Another Pop") {
  let alert = UIAlertController(
    title: "Hi Storybook",
    message: "As like this, you can present any view controller to check the behavior.",
    preferredStyle: .alert
  )
  alert.addAction(.init(title: "Got it", style: .default, handler: { _ in }))
  return alert
}
```

<img width=320 src="https://user-images.githubusercontent.com/1888355/82449728-a20ae500-9ae6-11ea-9ca0-1d93f7d45faf.gif" />

## Advanced Usage

**Creating a link to another pages for organizing**

Increasing the number of the components, the page would have long vertical scrolling.<br>
In this case, Storybook offers you to use `BookNavigationLink` to create another page.

```swift
let myBook = Book(title: "MyBook") {
  BookNavigationLink(title: "UISwitch") {
    BookPreview {
      let button = UISwitch()
      button.isOn = true
      return button
    }
    .title("UISwitch on")

    BookPreview {
      let button = UISwitch()
      button.isOn = false
      return button
    }
    .title("UISwitch off")
  }
}
```

<img width=320 src="https://user-images.githubusercontent.com/1888355/82448459-b3eb8880-9ae4-11ea-80f3-e663339ad5e6.gif" />

**Markup**

We can add some descriptions and headlines to clarify what the component is for.

```swift
let myBook = Book(title: "MyBook") {
  BookNavigationLink(title: "UISwitch") {
    BookPage(title: "UISwitch variations") {

      BookHeadline("This page previews UISwitch's state.")

      BookParagraph("""
Mainly, UISwitch has 2 states that are `on` or `off`.
This page shows you how it presents appearances in each state.
""")

      BookPreview {
        let button = UISwitch()
        button.isOn = true
        return button
      }
      .title("UISwitch on")

      BookPreview {
        let button = UISwitch()
        button.isOn = false
        return button
      }
      .title("UISwitch off")
    }
  }
}
```

<img width=320 src="https://user-images.githubusercontent.com/1888355/82449189-cca86e00-9ae5-11ea-8e54-d1e43bb276f6.gif" />

You can use following declarations to mark up.

- `BookPage`
- `BookSection`
- `BookParagraph`
- `BookHeadline`
- `BookText`


**Separates the declarations**

With increasing the number of the components and many descriptions, the declarations of the Book also have many lines of the code.<br>
In this case, we can separate the code with several functions.

```swift
let myBook = Book(title: "MyBook") {
  uiswitchPage()
}

func uiswitchPage() -> BookView {
  BookNavigationLink(title: "UISwitch") {
    BookPreview {
      let button = UISwitch()
      button.isOn = true
      return button
    }
    .title("UISwitch on")

    BookPreview {
      let button = UISwitch()
      button.isOn = false
      return button
    }
    .title("UISwitch off")
  }
}
```

**Make patterns of UI component**

To check the appearance of UI component that changes depends on input parameters, we can generate that patterns with `BookForEach` and `BookPattern`.

```swift
BookForEach(data: BookPattern.make(
  ["A", "AAA", "AAAAAA"],
  [UIColor.blue, UIColor.red, UIColor.orange]
)) { (args) in
  BookPreview {
    let (text, color) = args
    let label = UILabel()
    label.text = text
    label.textColor = color
    return label
  }
}
```

<img width=320 src="https://user-images.githubusercontent.com/1888355/82776162-f5818800-9e84-11ea-9505-8512dc6f8401.png" />


## Project structure to get faster developing UI

Especially, in UIKit based application, it takes many times to build to check the changes for UI.<br>
The best way to reduce that time, create a separated module that contains UI components only which are used by the application.<br>
And create a new application target for running Storybook only.<br>
Finally, link the main app and the storybook app with that separated module.

While you're tuning them up, you can only build with the storybook app.

- UIComponent (Dynamic or Static library/framework)
  - MainApp (Executable)
  - StorybookApp (Executable)

## Template for creating libraries demo applications.

https://gist.github.com/muukii/482d45d91afe4c362882e05082baa621

## Requirements

- iOS 10.0+
- Xcode 11.4+
- Swift 5.2+

## Installation

**CocoaPods** 

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate Alamofire into your Xcode project using CocoaPods, specify it in your Podfile:

```ruby
pod 'StorybookKit'
```

```ruby
pod 'StorybookUI'
```

```ruby
pod 'StorybookKitTextureSupport'
```

## License

Storybook-ios is released under the MIT license.


