@testable import Spots
import Foundation
import XCTest

class ParserTests: XCTestCase {
  private let jsonEncoder = JSONEncoder()

  func testParsingJSONIntoComponentObjects() {
    let json: [String : Any] = [
      "components": [["title": "test"], ["title": "test"]]
    ]
    let objects: [Component] = Parser.parseComponents(json: json)

    XCTAssertTrue(objects.count == 2)
  }

  func testParsingDataIntoComponentObjects() throws {
    let json: [String : Any] = [
      "components": [["title": "test"], ["title": "test"]]
    ]
    let data = try jsonEncoder.encode(json: json)
    let objects: [Component] = Parser.parseComponents(data: data)

    XCTAssertTrue(objects.count == 2)
  }

  func testParsingJSONIntoComponentObjectsWithCustomKey() {
    let json: [String : Any] = [
      "custom-key": [["title": "test"], ["title": "test"]]
    ]
    let objects: [Component] = Parser.parseComponents(json: json, key: "custom-key")

    XCTAssertTrue(objects.count == 2)
  }

  func testParsingDataIntoComponentObjectsWithCustomKey() throws {
    let json: [String : Any] = [
      "custom-key": [["title": "test"], ["title": "test"]]
    ]
    let data = try jsonEncoder.encode(json: json)
    let objects: [Component] = Parser.parseComponents(data: data, key: "custom-key")

    XCTAssertTrue(objects.count == 2)
  }

  func testParsingJSONIntoComponentModels() {
    let json: [String : Any] = [
      "components": [["title": "test"], ["title": "test"]]
    ]
    let components: [ComponentModel] = Parser.parseComponentModels(json: json)

    XCTAssertTrue(components.count == 2)
  }

  func testParsingDataIntoComponentModels() throws {
    let json: [String : Any] = [
      "components": [["title": "test"], ["title": "test"]]
    ]
    let data = try jsonEncoder.encode(json: json)
    let components: [ComponentModel] = Parser.parseComponentModels(data: data)

    XCTAssertTrue(components.count == 2)
  }

  func testParsingJSONIntoComponentModelsWithCustomKey() {
    let json: [String : Any] = [
      "objects": [["title": "test"], ["title": "test"]]
    ]
    let components: [ComponentModel] = Parser.parseComponentModels(json: json, key: "objects")

    XCTAssertTrue(components.count == 2)
  }

  func testParsingDataIntoComponentModelsWithCustomKey() throws {
    let json: [String : Any] = [
      "objects": [["title": "test"], ["title": "test"]]
    ]
    let data = try jsonEncoder.encode(json: json)
    let components: [ComponentModel] = Parser.parseComponentModels(data: data, key: "objects")

    XCTAssertTrue(components.count == 2)
  }

  func testParsingJSONIntoComponentModelsWithFaultyCustomKey() {
    let json: [String : Any] = [
      "components": [["title": "test"], ["title": "test"]]
    ]

    let components: [ComponentModel] = Parser.parseComponentModels(json: json, key: "objects")
    XCTAssertTrue(components.count == 0)
  }
}
