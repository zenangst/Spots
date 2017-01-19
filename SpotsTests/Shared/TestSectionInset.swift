@testable import Spots
import XCTest

class TestSectionInset: XCTestCase {

  let json: [String : Any] = [
    "top" : 5.0,
    "left" : 6.0,
    "bottom" : 7.0,
    "right" : 8.0
  ]

  func testJSONMapping() {
    var sectionInset = SectionInset([:])
    sectionInset.configure(withJSON: json)

    XCTAssertEqual(sectionInset, SectionInset(top: 5, left: 6, bottom: 7, right: 8))
  }
}
