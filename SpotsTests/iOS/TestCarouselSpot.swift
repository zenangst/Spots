@testable import Spots
import Brick
import Foundation
import XCTest

class CarouselSpotTests: XCTestCase {

  func testConvenienceInitWithSectionInsets() {
    let component = Component()
    let spot = CarouselSpot(component,
                        top: 5, left: 10, bottom: 5, right: 10, itemSpacing: 5)

    XCTAssertEqual(spot.layout.sectionInset, UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
    XCTAssertEqual(spot.layout.minimumInteritemSpacing, 5)
  }

  func testDictionaryRepresentation() {
    let component = Component(title: "CarouselSpot", kind: "carousel", span: 3, meta: ["headerHeight" : 44.0])
    let spot = CarouselSpot(component: component)
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
    let component = Component(title: "CarouselSpot", kind: "custom-carousel", items: [ViewModel(title: "foo", kind: "custom-item-kind")])
    let carouselSpot = CarouselSpot(component: component)
    let indexPath = NSIndexPath(forRow: 0, inSection: 0)

    XCTAssertEqual(carouselSpot.identifier(indexPath), CarouselSpot.views.defaultIdentifier)

    CarouselSpot.views.defaultItem = Registry.Item.classType(CarouselSpotCell.self)
    XCTAssertEqual(carouselSpot.identifier(indexPath),CarouselSpot.views.defaultIdentifier)

    CarouselSpot.views.defaultItem = Registry.Item.classType(CarouselSpotCell.self)
    XCTAssertEqual(carouselSpot.identifier(indexPath),CarouselSpot.views.defaultIdentifier)

    CarouselSpot.views["custom-item-kind"] = Registry.Item.classType(CarouselSpotCell.self)
    XCTAssertEqual(carouselSpot.identifier(indexPath), "custom-item-kind")

    CarouselSpot.views.storage.removeAll()
  }
}
