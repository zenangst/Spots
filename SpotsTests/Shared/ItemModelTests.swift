@testable import Spots
import Foundation
import XCTest

class ItemModelTests: XCTestCase {

  struct EquatableSubjectA: ItemModel, Equatable {
    static func ==(lhs: EquatableSubjectA, rhs: EquatableSubjectA) -> Bool {
      return lhs.identifier == rhs.identifier
    }
    let identifier: String
  }

  struct EquatableSubjectB: ItemModel, Equatable {
    static func ==(lhs: EquatableSubjectB, rhs: EquatableSubjectB) -> Bool {
      return lhs.identifier == rhs.identifier
    }
    let identifier: String
  }

  func testEqualToOnItemModel() {
    struct SubjectA: ItemModel {
      let identifier: String
    }

    struct SubjectB: ItemModel {
      let identifier: String
    }

    // Compare two equal objects
    do {
      let a = SubjectA(identifier: "foo")
      let b = SubjectA(identifier: "foo")
      XCTAssertTrue(a.equal(to: b))
    }

    // Compare two equal objects with different identifiers
    do {
      let a = SubjectA(identifier: "foo")
      let b = SubjectA(identifier: "bar")
      XCTAssertFalse(a.equal(to: b))
    }

    // Compare two objects with the same identifier signature but with different types.
    do {
      let a = SubjectA(identifier: "foo")
      let b = SubjectB(identifier: "foo")
      XCTAssertFalse(a.equal(to: b))
    }

    // Compare two objects with unequal identifier and with different types.
    do {
      let a = SubjectA(identifier: "foo")
      let b = SubjectB(identifier: "bar")
      XCTAssertFalse(a.equal(to: b))
    }
  }

  func testEqualToWithEquatables() {
    do {
      let a = EquatableSubjectA(identifier: "foo")
      let b = EquatableSubjectA(identifier: "foo")
      XCTAssertTrue(a.equal(to: b))
    }
  }
}
