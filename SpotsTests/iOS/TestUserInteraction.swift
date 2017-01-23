@testable import Spots
import XCTest

class InteractionTests: XCTestCase {

  func testDefaultValues() {
    let interaction = Interaction()

    XCTAssertEqual(interaction.paginate, .disabled)
  }

  func testRegularInit() {
    let interaction = Interaction()

    XCTAssertEqual(interaction.paginate, .disabled)
  }

  func testInitWithPaginateByPage() {
    let interaction = Interaction(paginate: .byPage)

    XCTAssertEqual(interaction.paginate, .byPage)
  }

  func testInitWithPaginateByItem() {
    let interaction = Interaction(paginate: .byItem)

    XCTAssertEqual(interaction.paginate, .byItem)
  }

  func testJSONMapping() {
    var json: [String : Any] = [
      "paginate" : "by-page"
    ]

    var interaction = Interaction(json)
    XCTAssertEqual(interaction.paginate, .byPage)

    json = [
      "paginate" : "by-item"
    ]

    interaction = Interaction(json)
    XCTAssertEqual(interaction.paginate, .byItem)

    json = [
      "paginate" : "disabled"
    ]

    interaction = Interaction(json)
    XCTAssertEqual(interaction.paginate, .disabled)

    interaction = Interaction([:])
    XCTAssertEqual(interaction.paginate, .disabled)
  }

  func testLegacyMapping() {
    let json: [String : Any] = [
      "paginate" : true
    ]

    Component.legacyMapping = true
    let interaction = Interaction(json)
    Component.legacyMapping = false

    XCTAssertTrue(interaction.paginate == .byPage)
  }

  func testDictionary() {
    let json: [String : Any] = [
      "paginate" : "by-page"
    ]

    let interaction = Interaction(json)

    XCTAssertTrue((interaction.dictionary as NSDictionary).isEqual(to: json))
  }

  func testEquality() {
    let json: [String : Any] = [
      "paginate" : "by-page"
    ]

    var lhs = Interaction(paginate: .byPage)
    let rhs = Interaction(json)

    XCTAssertTrue(lhs == rhs)

    lhs = Interaction(paginate: .byItem)
    XCTAssertTrue(lhs != rhs)
  }
}
