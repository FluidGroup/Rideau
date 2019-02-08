//
//  InternalUtils.swift
//  Cabinet
//
//  Created by muukii on 9/24/18.
//  Copyright © 2018 muukii. All rights reserved.
//

import Foundation
import CoreGraphics.CGGeometry

struct Progress {

  var fractionCompleted: CGFloat

  init(_ fractionCompleted: CGFloat) {
    self.fractionCompleted = fractionCompleted
  }
}

struct CalcBox<T> {

  var value: T

  init(_ value: T) {
    self.value = value
  }
}

extension CalcBox where T == CGFloat {

  func clip(min: CGFloat, max: CGFloat) -> CalcBox<CGFloat> {
    return .init(Swift.max(Swift.min(value, max), min))
  }

  func progress(start: CGFloat, end: CGFloat) -> CalcBox<Progress> {
    return .init(Progress.init((value - start) / (end - start)))
  }
}

extension CalcBox where T == Progress {

  func reverse() -> CalcBox<Progress> {
    return .init(Progress(1 - value.fractionCompleted))
  }

  func transition(start: CGFloat, end: CGFloat) -> CalcBox<CGFloat> {
    return .init(((end - start) * value.fractionCompleted) + start)
  }

  func clip(min: CGFloat, max: CGFloat) -> CalcBox<Progress> {
    return .init(Progress(Swift.max(Swift.min(value.fractionCompleted, max), min)))
  }
}

extension CalcBox where T == CGPoint {

  func vector() -> CalcBox<CGVector> {
    return .init(CGVector(dx: value.x, dy: value.y))
  }

  func distance(from: CGPoint) -> CalcBox<CGFloat> {
    return .init(sqrt(pow(value.x - from.x, 2) + pow(value.y - from.y, 2)))
  }

  func distance(to: CGPoint) -> CalcBox<CGFloat> {
    return .init(sqrt(pow(to.x - value.x, 2) + pow(to.y - value.y, 2)))
  }
}

extension CalcBox where T == CGVector {
  func magnitude() -> CGFloat {
    return sqrt(pow(value.dx, 2) + pow(value.dy, 2))
  }
}
