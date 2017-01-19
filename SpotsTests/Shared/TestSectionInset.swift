@testable import Spots
import XCTest

class TestSectionInset: XCTestCase {

  let json: [String : Any] = [
    "top" : 5.0,
    "left" : 6.0,
    "bottom" : 7.0,
    "right" : 8.0
  ]

  func testDefaultValues() {
    let sectionInset = SectionInset()

    XCTAssertEqual(sectionInset.top, 0.0)
    XCTAssertEqual(sectionInset.left, 0.0)
    XCTAssertEqual(sectionInset.bottom, 0.0)
    XCTAssertEqual(sectionInset.right, 0.0)
  }

  func testJSONMapping() {
    var sectionInset = SectionInset([:])
    sectionInset.configure(withJSON: json)

    XCTAssertEqual(sectionInset, SectionInset(top: 5, left: 6, bottom: 7, right: 8))
  }

  func testDictionaryConvertible() {
    let sectionInset = SectionInset(json)
    let sectionInsetJSON = sectionInset.dictionary

    XCTAssertEqual(sectionInsetJSON["top"], sectionInset.top)
    XCTAssertEqual(sectionInsetJSON["left"], sectionInset.left)
    XCTAssertEqual(sectionInsetJSON["bottom"], sectionInset.bottom)
    XCTAssertEqual(sectionInsetJSON["right"], sectionInset.right)
  }

  func testBlockConfiguration() {
    let sectionInset = SectionInset {
      $0.top = 5
      $0.left = 6
      $0.bottom = 7
      $0.right = 8
    }

    XCTAssertEqual(sectionInset, SectionInset(top: 5, left: 6, bottom: 7, right: 8))
  }
}
