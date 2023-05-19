import UIKit

protocol PatchType {
  associatedtype Value
}

struct ProgressPatch: PatchType {

  typealias Value = CGFloat

  var fractionCompleted: Value

  init(_ fractionCompleted: Value) {
    self.fractionCompleted = fractionCompleted
  }

  func reverse() -> ProgressPatch {
    return ProgressPatch(1 - fractionCompleted)
  }

  func transition(start: CGFloat, end: CGFloat) -> ValuePatch {
    return .init(((end - start) * fractionCompleted) + start)
  }

  func clip(min: CGFloat, max: CGFloat) -> ProgressPatch {
    return ProgressPatch(Swift.max(Swift.min(fractionCompleted, max), min))
  }

  func progress(start: CGFloat, end: CGFloat) -> ProgressPatch {
    return ValuePatch(fractionCompleted)
      .progress(start: start, end: end)
  }
}

struct ValuePatch: PatchType {

  typealias Value = CGFloat

  var value: Value

  init(_ value: Value) {
    self.value = value
  }

  func clip(min: CGFloat, max: CGFloat) -> ValuePatch {
    return .init(Swift.max(Swift.min(value, max), min))
  }

  func progress(start: CGFloat, end: CGFloat) -> ProgressPatch {
    return ProgressPatch.init((value - start) / (end - start))
  }
}

struct PointPatch: PatchType {

  typealias Value = CGPoint

  var value: Value

  init(_ value: Value) {
    self.value = value
  }

  func vector() -> VectorPatch {
    return .init(CGVector(dx: value.x, dy: value.y))
  }

  func distance(from: CGPoint) -> ValuePatch {
    return .init(sqrt(pow(value.x - from.x, 2) + pow(value.y - from.y, 2)))
  }

  func distance(to: CGPoint) -> ValuePatch {
    return .init(sqrt(pow(to.x - value.x, 2) + pow(to.y - value.y, 2)))
  }
}

struct VectorPatch: PatchType {
  typealias Value = CGVector

  var value: Value

  init(_ value: Value) {
    self.value = value
  }

  func magnitude() -> CGFloat {
    return sqrt(pow(value.dx, 2) + pow(value.dy, 2))
  }
}


