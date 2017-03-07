@testable import Spots
import Foundation
import XCTest

class ParserTests: XCTestCase {

  func testParsingJSONIntoCoreComponentObjects() {
    let json: [String : Any] = [
      "components": [["title": "test"], ["title": "test"]]
    ]

    let objects: [CoreComponent] = Parser.parse(json)
    XCTAssertTrue(objects.count == 2)
  }

  func testParsingJSONIntoCoreComponentObjectsWithCustomKey() {
    let json: [String : Any] = [
      "custom-key": [["title": "test"], ["title": "test"]]
    ]

    let objects: [CoreComponent] = Parser.parse(json, key: "custom-key")
    XCTAssertTrue(objects.count == 2)
  }

  func testParsingJSONIntoCoreComponentObjectsWithoutKey() {
    let json: [[String : Any]] = [
      ["title": "test"], ["title": "test"]
    ]

    let objects: [CoreComponent] = Parser.parse(json)
    XCTAssertTrue(objects.count == 2)
  }

  func testParsingJSONIntoCoreComponentObjectsWithEmptyJSON() {
    let objects: [CoreComponent] = Parser.parse(nil)
    XCTAssertTrue(objects.count == 0)
  }

  func testParsingJSONIntoComponentModels() {
    let json: [String : Any] = [
      "components": [["title": "test"], ["title": "test"]]
    ]

    let components: [ComponentModel] = Parser.parse(json)
    XCTAssertTrue(components.count == 2)
  }

  func testParsingJSONIntoComponentModelsWithCustomKey() {
    let json: [String : Any] = [
      "objects": [["title": "test"], ["title": "test"]]
    ]

    let components: [ComponentModel] = Parser.parse(json, key: "objects")
    XCTAssertTrue(components.count == 2)
  }

  func testParsingJSONIntoComponentModelsWithFaultyCustomKey() {
    let json: [String : Any] = [
      "components": [["title": "test"], ["title": "test"]]
    ]

    let components: [ComponentModel] = Parser.parse(json, key: "objects")
    XCTAssertTrue(components.count == 0)
  }
}
