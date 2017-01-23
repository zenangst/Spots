@testable import Spots
import XCTest

class UserInteractionTests: XCTestCase {

  func testDefaultValues() {
    let userInteraction = UserInteraction()

    XCTAssertEqual(userInteraction.paginate, .disabled)
  }

  func testRegularInit() {
    let userInteraction = UserInteraction()

    XCTAssertEqual(userInteraction.paginate, .disabled)
  }

  func testInitWithPaginateByPage() {
    let userInteraction = UserInteraction(paginate: .byPage)

    XCTAssertEqual(userInteraction.paginate, .byPage)
  }

  func testInitWithPaginateByItem() {
    let userInteraction = UserInteraction(paginate: .byItem)

    XCTAssertEqual(userInteraction.paginate, .byItem)
  }

  func testJSONMapping() {
    var json: [String : Any] = [
      "paginate" : "by-page"
    ]

    var userInteraction = UserInteraction(json)
    XCTAssertEqual(userInteraction.paginate, .byPage)

    json = [
      "paginate" : "by-item"
    ]

    userInteraction = UserInteraction(json)
    XCTAssertEqual(userInteraction.paginate, .byItem)

    json = [
      "paginate" : "disabled"
    ]

    userInteraction = UserInteraction(json)
    XCTAssertEqual(userInteraction.paginate, .disabled)

    userInteraction = UserInteraction([:])
    XCTAssertEqual(userInteraction.paginate, .disabled)
  }

  func testLegacyMapping() {
    let json: [String : Any] = [
      "paginate" : true
    ]

    Component.legacyMapping = true
    let userInteraction = UserInteraction(json)
    Component.legacyMapping = false

    XCTAssertTrue(userInteraction.paginate == .byPage)
  }

  func testDictionary() {
    let json: [String : Any] = [
      "paginate" : "by-page"
    ]

    let userInteraction = UserInteraction(json)

    XCTAssertTrue((userInteraction.dictionary as NSDictionary).isEqual(to: json))
  }

  func testEquality() {
    let json: [String : Any] = [
      "paginate" : "by-page"
    ]

    var lhs = UserInteraction(paginate: .byPage)
    let rhs = UserInteraction(json)

    XCTAssertTrue(lhs == rhs)

    lhs = UserInteraction(paginate: .byItem)
    XCTAssertTrue(lhs != rhs)
  }
}
