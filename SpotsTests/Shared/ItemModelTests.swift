@testable import Spots
import Foundation
import XCTest

final class ItemModelTests: XCTestCase {
  func testEqualToWithEquatables() {
    // When equal
    do {
        let a = "foo"
        let b = "foo"
        XCTAssertTrue(a.equal(to: b))
    }
    
    // When not equal
    do {
      let a = "foo"
      let b = "bar"
      XCTAssertFalse(a.equal(to: b))
    }
  }

  func testEqualToWithEquatablesOfDifferentTypes() {
    let a = "foo"
    let b = 1
    XCTAssertFalse(a.equal(to: b))
  }
}

extension String: ItemModel {}
extension Int: ItemModel {}
