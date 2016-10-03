@testable import Spots
import Brick
import Foundation
import XCTest

class GirdSpotTests: XCTestCase {

  func testConvenienceInitWithTitleAndKind() {
    let spot = GridSpot(title: "Spot")
    XCTAssertEqual(spot.component.title, "Spot")

    XCTAssertEqual(spot.component.kind, "grid")

    let customKindSpot = GridSpot(title: "Custom Spot", kind: "custom")
    XCTAssertEqual(customKindSpot.component.title, "Custom Spot")
    XCTAssertEqual(customKindSpot.component.kind, "custom")
  }

  func testConvenienceInitWithSectionInsets() {
    let component = Component()
    let spot = GridSpot(component,
                            top: 5, left: 10, bottom: 5, right: 10, itemSpacing: 5)

    XCTAssertEqual(spot.layout.sectionInset, UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
    XCTAssertEqual(spot.layout.minimumInteritemSpacing, 5)
  }

  func testDictionaryRepresentation() {
    let component = Component(title: "GridSpot", kind: "grid", span: 3, meta: ["headerHeight" : 44.0])
    let spot = GridSpot(component: component)
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
    let component = Component(title: "GridSpot", kind: "custom-grid", items: [Item(title: "foo", kind: "custom-item-kind")])
    let gridSpot = GridSpot(component: component)
    let indexPath = IndexPath(row: 0, section: 0)

    XCTAssertEqual(gridSpot.identifier(indexPath), GridSpot.views.defaultIdentifier)
    
    GridSpot.views.defaultItem = Registry.Item.classType(GridSpotCell.self)
    XCTAssertEqual(gridSpot.identifier(indexPath),GridSpot.views.defaultIdentifier)
    
    GridSpot.views.defaultItem = Registry.Item.classType(GridSpotCell.self)
    XCTAssertEqual(gridSpot.identifier(indexPath),GridSpot.views.defaultIdentifier)
    
    GridSpot.views["custom-item-kind"] = Registry.Item.classType(GridSpotCell.self)
    XCTAssertEqual(gridSpot.identifier(indexPath), "custom-item-kind")
    
    GridSpot.views.storage.removeAll()
  }
}
