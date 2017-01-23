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
    let interaction = Interaction(paginate: .page)

    XCTAssertEqual(interaction.paginate, .page)
  }

  func testInitWithPaginateByItem() {
    let interaction = Interaction(paginate: .item)

    XCTAssertEqual(interaction.paginate, .item)
  }

  func testJSONMapping() {
    var json: [String : Any] = [
      "paginate" : "page"
    ]

    var interaction = Interaction(json)
    XCTAssertEqual(interaction.paginate, .page)

    json = [
      "paginate" : "item"
    ]

    interaction = Interaction(json)
    XCTAssertEqual(interaction.paginate, .item)

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

    XCTAssertTrue(interaction.paginate == .page)
  }

  func testDictionary() {
    let json: [String : Any] = [
      "paginate" : "page"
    ]

    let interaction = Interaction(json)

    XCTAssertTrue((interaction.dictionary as NSDictionary).isEqual(to: json))
  }

  func testEquality() {
    let json: [String : Any] = [
      "paginate" : "page"
    ]

    var lhs = Interaction(paginate: .page)
    let rhs = Interaction(json)

    XCTAssertTrue(lhs == rhs)

    lhs = Interaction(paginate: .item)
    XCTAssertTrue(lhs != rhs)
  }
}
