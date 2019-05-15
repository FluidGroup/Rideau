//
//  TransitionPatchTests.swift
//  TransitionPatchTests
//
//  Created by muukii on 2019/05/13.
//  Copyright © 2019 muukii. All rights reserved.
//

import XCTest
@testable import TransitionPatch

class TransitionPatchTests: XCTestCase {
  
  func testProgress() {
    
    let value = ValuePatch(10)
      .progress(start: 0, end: 20)
      .clip(min: 0, max: 1)
      .fractionCompleted
    
    XCTAssertEqual(value, 0.5)
    
  }
  
  func testPerformanceExample() {
    
    self.measure {
      // Put the code you want to measure the time of here.
    }
    
  }
  
}
