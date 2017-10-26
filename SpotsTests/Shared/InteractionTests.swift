@testable import Spots
import XCTest
import Foundation

class InteractionTests: XCTestCase {
  private let jsonEncoder = JSONEncoder()
  private let jsonDecoder = JSONDecoder()

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

  func testDecoding() throws {
    var json: [String : Any] = [
      "paginate": "page"
    ]

    var data = try jsonEncoder.encode(json: json)
    var interaction = try jsonDecoder.decode(Interaction.self, from: data)
    XCTAssertEqual(interaction.paginate, .page)

    json = [
      "paginate": "item",
      "mouseClick" : "single"
    ]

    data = try jsonEncoder.encode(json: json)
    interaction = try jsonDecoder.decode(Interaction.self, from: data)
    XCTAssertEqual(interaction.paginate, .item)
    XCTAssertEqual(interaction.mouseClick, .single)

    json = [
      "paginate": "disabled",
      "mouseClick": "double"
    ]

    data = try jsonEncoder.encode(json: json)
    interaction = try jsonDecoder.decode(Interaction.self, from: data)
    XCTAssertEqual(interaction.paginate, .disabled)
    XCTAssertEqual(interaction.mouseClick, .double)

    interaction = Interaction()
    XCTAssertEqual(interaction.paginate, .disabled)
    XCTAssertEqual(interaction.mouseClick, .single)
  }

  func testEncoding() throws {
    let interaction = Interaction(paginate: .item, mouseClick: .double)
    let data = try jsonEncoder.encode(interaction)
    let decodedInteraction = try jsonDecoder.decode(Interaction.self, from: data)

    XCTAssertTrue(interaction == decodedInteraction)
  }

  func testEquality() {
    var lhs = Interaction(paginate: .page)
    let rhs = Interaction(paginate: .page)

    XCTAssertTrue(lhs == rhs)

    lhs = Interaction(paginate: .item)
    XCTAssertTrue(lhs != rhs)
  }
}
