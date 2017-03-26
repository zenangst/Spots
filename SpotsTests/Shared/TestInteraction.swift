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
      "paginate": "page"
    ]

    var interaction = Interaction(json)
    XCTAssertEqual(interaction.paginate, .page)

    json = [
      "paginate": "item",
      "mouseClick" : "single"
    ]

    interaction = Interaction(json)
    XCTAssertEqual(interaction.paginate, .item)
    XCTAssertEqual(interaction.mouseClick, .single)

    json = [
      "paginate": "disabled",
      "mouseClick": "double"
    ]

    interaction = Interaction(json)
    XCTAssertEqual(interaction.paginate, .disabled)
    XCTAssertEqual(interaction.mouseClick, .double)

    interaction = Interaction()
    XCTAssertEqual(interaction.paginate, .disabled)
    XCTAssertEqual(interaction.mouseClick, .single)
  }

  func testDictionary() {
    let json: [String : Any] = [
      "paginate": "page",
      "mouseClick" : "single"
    ]

    let interaction = Interaction(json)

    XCTAssertTrue((interaction.dictionary as NSDictionary).isEqual(to: json))
  }

  func testEquality() {
    let json: [String : Any] = [
      "paginate": "page"
    ]

    var lhs = Interaction(paginate: .page)
    let rhs = Interaction(json)

    XCTAssertTrue(lhs == rhs)

    lhs = Interaction(paginate: .item)
    XCTAssertTrue(lhs != rhs)
  }
}
