//
// NibLoader.swift
//
// Copyright (c) 2017 muukii
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

import UIKit

public struct NibLoader<T: UIView> {
  
  public let name: String?
  public let bundle: Bundle?
  
  public init(name: String? = nil, bundle: Bundle? = nil) {
    self.name = name
    self.bundle = bundle
  }
  
  func nib() -> UINib {
    return UINib(nibName: name ?? String(describing: T.self), bundle: bundle ?? Bundle(for: T.self))
  }
  
  public func load() -> T {
    let nib = self.nib()
    guard let view = nib.instantiate(withOwner: nil, options: nil).first as? T else {
      fatalError("The nib \(nib) expected its root view to be of type \(T.self)")
    }
    return view
  }
}
