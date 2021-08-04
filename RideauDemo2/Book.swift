import StorybookKit

let book = Book(title: "Rideau Demo") {

  BookSection(title: "Cases") {
    BookNavigationLink(title: "Inline") {
      BookPush(title: "hoge") {
        DemoInlineViewController(contentView: SampleView())
      }
    }
  }
}
