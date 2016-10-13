@testable import Spots
import Brick
import Foundation
import XCTest

class ViewSpotTests: XCTestCase {

  func testConvenienceInitWithTitleAndKind() {
    let spot = ViewSpot(title: "Spot")
    XCTAssertEqual(spot.component.title, "Spot")

    XCTAssertEqual(spot.component.kind, "view")

    let customKindSpot = ViewSpot(title: "Custom Spot", kind: "custom")
    XCTAssertEqual(customKindSpot.component.title, "Custom Spot")
    XCTAssertEqual(customKindSpot.component.kind, "custom")
  }

  func testDictionaryRepresentation() {
    let component = Component(title: "ViewSpot", kind: "view", span: 3, meta: ["headerHeight" : 44.0])
    let spot = ViewSpot(component: component)
    XCTAssertEqual(component.dictionary["index"] as? Int, spot.dictionary["index"] as? Int)
    XCTAssertEqual(component.dictionary["title"] as? String, spot.dictionary["title"] as? String)
    XCTAssertEqual(component.dictionary["kind"] as? String, spot.dictionary["kind"] as? String)
    XCTAssertEqual(component.dictionary["span"] as? Int, spot.dictionary["span"] as? Int)
    XCTAssertEqual(
      (component.dictionary["meta"] as! [String : Any])["headerHeight"] as? CGFloat,
      (spot.dictionary["meta"] as! [String : Any])["headerHeight"] as? CGFloat
    )
  }
}
