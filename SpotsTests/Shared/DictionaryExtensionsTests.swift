import XCTest
@testable import Spots

class DictionaryExtensionsTests: XCTestCase {
  func testSubscriptingExtension() {
    var dictionary = [String: String]()
    let actionValue = "action"
    dictionary[Item.Key.action] = actionValue

    XCTAssertEqual(dictionary[Item.Key.action], actionValue)
    XCTAssertNotEqual(dictionary[Item.Key.height], actionValue)
  }
}
