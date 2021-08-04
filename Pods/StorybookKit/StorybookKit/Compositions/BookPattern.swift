//
// Copyright (c) 2020 Eureka, Inc.
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

import Foundation

public struct BookPattern<Element>: Sequence {

  public typealias Iterator = PatternIterator

  var _makeIterator: () -> AnyIterator<Element>

  init(_ source: [Element]) {
    self._makeIterator = {
      var s = source.makeIterator()
      return AnyIterator.init {
        s.next()
      }
    }
  }

  public __consuming func makeIterator() -> PatternIterator {
    PatternIterator.init(source: _makeIterator())
  }

  public struct PatternIterator: IteratorProtocol {

    var source: AnyIterator<Element>

    init(source: AnyIterator<Element>) {
      self.source = source
    }

    public mutating func next() -> Element? {
      source.next()
    }
  }
}

extension BookPattern where Element == Any {

  public static func make<P0: Sequence>(_ p0: P0) -> BookPattern<(P0.Element)> {
    .init(p0.map { $0 })
  }

  public static func make<P0: Sequence, P1: Sequence>(_ p0: P0, _ p1: P1) -> BookPattern<(P0.Element, P1.Element)> {

    var buffer: [(P0.Element, P1.Element)] = []

    p0.forEach { p0 in
      p1.forEach { p1 in
        buffer.append((p0, p1))
      }
    }

    return .init(buffer)

  }

  public static func make<P0: Sequence, P1: Sequence, P2: Sequence>(_ p0: P0, _ p1: P1, _ p2: P2) -> BookPattern<(P0.Element, P1.Element, P2.Element)> {

    var buffer: [(P0.Element, P1.Element, P2.Element)] = []

    p0.forEach { p0 in
      p1.forEach { p1 in
        p2.forEach { p2 in
          buffer.append((p0, p1, p2))
        }
      }
    }

    return .init(buffer)

  }

  public static func make<P0: Sequence, P1: Sequence, P2: Sequence, P3: Sequence>(_ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3) -> BookPattern<(P0.Element, P1.Element, P2.Element, P3.Element)> {

    var buffer: [(P0.Element, P1.Element, P2.Element, P3.Element)] = []

    p0.forEach { p0 in
      p1.forEach { p1 in
        p2.forEach { p2 in
          p3.forEach { p3 in
            buffer.append((p0, p1, p2, p3))
          }
        }
      }
    }

    return .init(buffer)

  }

  public static func make<P0: Sequence, P1: Sequence, P2: Sequence, P3: Sequence, P4: Sequence>(_ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4) -> BookPattern<(P0.Element, P1.Element, P2.Element, P3.Element, P4.Element)> {

    var buffer: [(P0.Element, P1.Element, P2.Element, P3.Element, P4.Element)] = []

    p0.forEach { p0 in
      p1.forEach { p1 in
        p2.forEach { p2 in
          p3.forEach { p3 in
            p4.forEach { p4 in
              buffer.append((p0, p1, p2, p3, p4))
            }
          }
        }
      }
    }

    return .init(buffer)

  }

}
