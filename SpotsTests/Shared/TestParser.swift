@testable import Spots
import Foundation
import XCTest
import Brick

class ParserTests : XCTestCase {

  func testParsingJSONIntoSpotableObjects() {
    let json: [String : Any] = [
      "components" : [["title" : "test"], ["title" : "test"]]
    ]

    let objects: [Spotable] = Parser.parse(json)
    XCTAssertTrue(objects.count == 2)
  }

  func testParsingJSONIntoSpotableObjectsWithCustomKey() {
    let json: [String : Any] = [
      "custom-key" : [["title" : "test"], ["title" : "test"]]
    ]

    let objects: [Spotable] = Parser.parse(json, key: "custom-key")
    XCTAssertTrue(objects.count == 2)
  }

  func testParsingJSONIntoSpotableObjectsWithoutKey() {
    let json: [[String : Any]] = [
      ["title" : "test"], ["title" : "test"]
    ]

    let objects: [Spotable] = Parser.parse(json)
    XCTAssertTrue(objects.count == 2)
  }

  func testParsingJSONIntoSpotableObjectsWithEmptyJSON() {
    let objects: [Spotable] = Parser.parse(nil)
    XCTAssertTrue(objects.count == 0)
  }

  func testParsingJSONIntoComponents() {
    let json: [String : Any] = [
      "components" : [["title" : "test"], ["title" : "test"]]
    ]

    let components: [Component] = Parser.parse(json)
    XCTAssertTrue(components.count == 2)
  }

  func testParsingJSONIntoComponentsWithCustomKey() {
    let json: [String : Any] = [
      "objects" : [["title" : "test"], ["title" : "test"]]
    ]

    let components: [Component] = Parser.parse(json, key: "objects")
    XCTAssertTrue(components.count == 2)
  }

  func testParsingJSONIntoComponentsWithFaultyCustomKey() {
    let json: [String : Any] = [
      "components" : [["title" : "test"], ["title" : "test"]]
    ]

    let components: [Component] = Parser.parse(json, key: "objects")
    XCTAssertTrue(components.count == 0)
  }
}
