@testable import Spots
import Foundation
import XCTest

class ViewComponentTests: XCTestCase {

  func testDictionaryRepresentation() {
    let model = ComponentModel(title: "ViewComponent", kind: "view", span: 3, meta: ["headerHeight": 44.0])
    let spot = ViewComponent(model: model)
    XCTAssertEqual(model.dictionary["index"] as? Int, spot.dictionary["index"] as? Int)
    XCTAssertEqual(model.dictionary["title"] as? String, spot.dictionary["title"] as? String)
    XCTAssertEqual(model.dictionary["kind"] as? String, spot.dictionary["kind"] as? String)
    XCTAssertEqual(model.dictionary["span"] as? Int, spot.dictionary["span"] as? Int)
    XCTAssertEqual(
      (model.dictionary["meta"] as! [String : Any])["headerHeight"] as? CGFloat,
      (spot.dictionary["meta"] as! [String : Any])["headerHeight"] as? CGFloat
    )
  }
}
