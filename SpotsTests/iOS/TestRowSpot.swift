@testable import Spots
import Brick
import Foundation
import XCTest

class RowSpotTests: XCTestCase {

  func testConvenienceInitWithTitleAndKind() {
    let spot = RowSpot(title: "Spot")

    XCTAssertEqual(spot.component.title, "Spot")
    XCTAssertEqual(spot.component.kind, "row")

    let customKindSpot = RowSpot(title: "Custom Spot", kind: "custom")
    XCTAssertEqual(customKindSpot.component.title, "Custom Spot")
    XCTAssertEqual(customKindSpot.component.kind, "custom")
  }

  func testConvenienceInitWithSectionInsets() {
    let component = Component()
    let spot = RowSpot(component,
                        top: 5, left: 10, bottom: 5, right: 10, itemSpacing: 5)

    XCTAssertEqual(spot.layout.sectionInset, UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
    XCTAssertEqual(spot.layout.minimumInteritemSpacing, 5)
  }

  func testDictionaryRepresentation() {
    let component = Component(title: "RowSpot", kind: "row", span: 3, meta: ["headerHeight" : 44.0])
    let spot = RowSpot(component: component)
    XCTAssertEqual(component.dictionary["index"] as? Int, spot.dictionary["index"] as? Int)
    XCTAssertEqual(component.dictionary["title"] as? String, spot.dictionary["title"] as? String)
    XCTAssertEqual(component.dictionary["kind"] as? String, spot.dictionary["kind"] as? String)
    XCTAssertEqual(component.dictionary["span"] as? Int, spot.dictionary["span"] as? Int)
    XCTAssertEqual(
      (component.dictionary["meta"] as! [String : Any])["headerHeight"] as? CGFloat,
      (spot.dictionary["meta"] as! [String : Any])["headerHeight"] as? CGFloat
    )
  }

  func testSafelyResolveKind() {
    let component = Component(title: "RowSpot", kind: "custom-grid", items: [Item(title: "foo", kind: "custom-item-kind")])
    let rowSpot = RowSpot(component: component)
    let indexPath = IndexPath(row: 0, section: 0)

    XCTAssertEqual(rowSpot.identifier(at: indexPath), RowSpot.views.defaultIdentifier)

    RowSpot.views.defaultItem = Registry.Item.classType(GridSpotCell.self)
    XCTAssertEqual(rowSpot.identifier(at: indexPath),RowSpot.views.defaultIdentifier)

    RowSpot.views.defaultItem = Registry.Item.classType(GridSpotCell.self)
    XCTAssertEqual(rowSpot.identifier(at: indexPath),RowSpot.views.defaultIdentifier)

    RowSpot.views["custom-item-kind"] = Registry.Item.classType(GridSpotCell.self)
    XCTAssertEqual(rowSpot.identifier(at: indexPath), "custom-item-kind")

    RowSpot.views.storage.removeAll()
  }
}
