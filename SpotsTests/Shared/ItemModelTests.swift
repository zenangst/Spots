@testable import Spots
import Foundation
import XCTest

class ItemModelTests: XCTestCase {

  struct EquatableSubjectA: ItemModel {
    let value: String
    static func ==(lhs: EquatableSubjectA, rhs: EquatableSubjectA) -> Bool {
      return lhs.value == rhs.value
    }
  }

  struct EquatableSubjectB: ItemModel, Equatable {
    let value: String
    static func ==(lhs: EquatableSubjectB, rhs: EquatableSubjectB) -> Bool {
      return lhs.value == rhs.value
    }
  }

  struct SubjectA: ItemCodable {
    let value: String
  }

  struct SubjectB: ItemCodable {
    let value: String
  }

  func testEqualToOnItemModel() {

    // Compare two equal objects
    do {
      let a = SubjectA(value: "foo")
      let b = SubjectA(value: "foo")

      XCTAssertTrue(a == b)
    }

    // Compare two equal objects with different identifiers
    do {
      let a = SubjectA(value: "foo")
      let b = SubjectA(value: "bar")
      XCTAssertFalse(a == b)
    }

    // Compare two objects with the same identifier signature but with different types.
    do {
      let a = SubjectA(value: "foo")
      let b = SubjectB(value: "foo")
      XCTAssertFalse(a == b)
    }

    // Compare two objects with unequal identifier and with different types.
    do {
      let a = SubjectA(value: "foo")
      let b = SubjectB(value: "bar")
      XCTAssertFalse(a == b)
    }
  }

  func testEquatableWithNonEquatable() {
    let a = EquatableSubjectA(value: "foo")
    let b = SubjectA(value: "foo")
    XCTAssertFalse(a == b)
  }

  func testEqualToWithEquatables() {
    do {
      let a = EquatableSubjectA(value: "foo")
      let b = EquatableSubjectA(value: "foo")
      XCTAssertTrue(a == b)
    }
  }
}
