@testable import Spots
import Foundation
import XCTest

class ViewComponentTests: XCTestCase {

  func testDictionaryRepresentation() {
    let model = ComponentModel(title: "ViewComponent", kind: "view", span: 3, meta: ["headerHeight": 44.0])
    let component = ViewComponent(model: model)
    XCTAssertEqual(model.dictionary["index"] as? Int, component.dictionary["index"] as? Int)
    XCTAssertEqual(model.dictionary["title"] as? String, component.dictionary["title"] as? String)
    XCTAssertEqual(model.dictionary["kind"] as? String, component.dictionary["kind"] as? String)
    XCTAssertEqual(model.dictionary["span"] as? Int, component.dictionary["span"] as? Int)
    XCTAssertEqual(
      (model.dictionary["meta"] as! [String : Any])["headerHeight"] as? CGFloat,
      (component.dictionary["meta"] as! [String : Any])["headerHeight"] as? CGFloat
    )
  }
}
