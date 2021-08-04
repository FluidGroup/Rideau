
@resultBuilder
public struct MondrianArrayBuilder<Element> {

  public static func buildBlock() -> [Element] {
    []
  }

  public static func buildBlock(_ content: Element) -> [Element] {
    [content]
  }

  public static func buildBlock(_ contents: Element...) -> [Element] {
    contents
  }

  public static func buildBlock(_ contents: [Element]) -> [Element] {
    contents
  }

  public static func buildBlock(_ contents: Element?...) -> [Element] {
    contents.compactMap { $0 }
  }

  public static func buildBlock(_ contents: [Element?]) -> [Element] {
    contents.compactMap { $0 }
  }

}
