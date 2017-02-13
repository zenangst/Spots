@testable import Spots
import XCTest

class TestInset: XCTestCase {

  let json: [String : Any] = [
    "top": 1.0,
    "left": 2.0,
    "bottom": 3.0,
    "right": 4.0
  ]

  func testDefaultValues() {
    let contentInset = Inset()

    XCTAssertEqual(contentInset.top, 0.0)
    XCTAssertEqual(contentInset.left, 0.0)
    XCTAssertEqual(contentInset.bottom, 0.0)
    XCTAssertEqual(contentInset.right, 0.0)
  }

  func testJSONMapping() {
    var contentInset = Inset()
    contentInset.configure(withJSON: json)

    XCTAssertEqual(contentInset, Inset(top: 1, left: 2, bottom: 3, right: 4))
  }

  func testDictionaryConvertible() {
    let contentInset = Inset(json)
    let contentInsetJSON = contentInset.dictionary

    XCTAssertEqual(contentInsetJSON["top"], contentInset.top)
    XCTAssertEqual(contentInsetJSON["left"], contentInset.left)
    XCTAssertEqual(contentInsetJSON["bottom"], contentInset.bottom)
    XCTAssertEqual(contentInsetJSON["right"], contentInset.right)
  }

  func testBlockConfiguration() {
    let contentInset = Inset {
      $0.top = 1
      $0.left = 2
      $0.bottom = 3
      $0.right = 4
    }

    XCTAssertEqual(contentInset, Inset(top: 1, left: 2, bottom: 3, right: 4))
  }
}
