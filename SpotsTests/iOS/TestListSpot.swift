@testable import Spots
import Brick
import Foundation
import XCTest

class ListSpotTests: XCTestCase {

  func testConvenienceInitWithTitleAndKind() {
    let spot = ListSpot(title: "Spot")
    XCTAssertEqual(spot.component.title, "Spot")

    XCTAssertEqual(spot.component.kind, "list")

    let customKindSpot = ListSpot(title: "Custom Spot", kind: "custom")
    XCTAssertEqual(customKindSpot.component.title, "Custom Spot")
    XCTAssertEqual(customKindSpot.component.kind, "custom")
  }

  func testDictionaryRepresentation() {
    let component = Component(title: "ListSpot", kind: "list", span: 3, meta: ["headerHeight" : 44.0])
    let spot = ListSpot(component: component)
    XCTAssertEqual(component.dictionary["index"] as? Int, spot.dictionary["index"] as? Int)
    XCTAssertEqual(component.dictionary["title"] as? String, spot.dictionary["title"] as? String)
    XCTAssertEqual(component.dictionary["kind"] as? String, spot.dictionary["kind"] as? String)
    XCTAssertEqual(component.dictionary["span"] as? Int, spot.dictionary["span"] as? Int)
    XCTAssertEqual(
      (component.dictionary["meta"] as! [String : AnyObject])["headerHeight"] as? CGFloat,
      (spot.dictionary["meta"] as! [String : AnyObject])["headerHeight"] as? CGFloat
    )
  }

  func testSafelyResolveKind() {
    let component = Component(title: "ListSpot", kind: "custom-list", items: [ViewModel(title: "foo", kind: "custom-item-kind")])
    let listSpot = ListSpot(component: component)
    let indexPath = NSIndexPath(forRow: 0, inSection: 0)

    XCTAssertEqual(listSpot.identifier(indexPath), ListSpot.views.defaultIdentifier)

    ListSpot.views.defaultItem = Registry.Item.classType(ListSpotCell.self)
    XCTAssertEqual(listSpot.identifier(indexPath),ListSpot.views.defaultIdentifier)

    ListSpot.views.defaultItem = Registry.Item.classType(ListSpotCell.self)
    XCTAssertEqual(listSpot.identifier(indexPath),ListSpot.views.defaultIdentifier)

    ListSpot.views["custom-item-kind"] = Registry.Item.classType(ListSpotCell.self)
    XCTAssertEqual(listSpot.identifier(indexPath), "custom-item-kind")

    ListSpot.views.storage.removeAll()
  }
}
