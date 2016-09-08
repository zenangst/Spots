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

  func testMetaMapping() {
    var json: [String : AnyObject] = [
      "meta" : [
        "item-spacing" : 25.0,
        "line-spacing" : 10.0,
        "dynamic-span" :  true
      ]
    ]

    var component = Component(json)
    var spot = CarouselSpot(component: component)
    spot.setup(CGSize(width: 100, height: 100))

    XCTAssertEqual(spot.layout.minimumInteritemSpacing, 25.0)
    XCTAssertEqual(spot.layout.minimumLineSpacing, 10.0)
    XCTAssertEqual(spot.dynamicSpan, true)

    json = [
      "meta" : [
        "item-spacing" : 12.5,
        "line-spacing" : 7.5,
        "dynamic-span" :  false
      ]
    ]

    component = Component(json)
    spot = CarouselSpot(component: component)
    spot.setup(CGSize(width: 100, height: 100))

    XCTAssertEqual(spot.layout.minimumInteritemSpacing, 12.5)
    XCTAssertEqual(spot.layout.minimumLineSpacing, 7.5)
    XCTAssertEqual(spot.dynamicSpan, false)
  }

  func testCarouselSetupWithSimpleStructure() {
    let json: [String : AnyObject] = [
      "items" : [
        ["title" : "foo",
          "size" : [
            "width" : 120,
            "height" : 180]
        ],
        ["title" : "bar",
          "size" : [
            "width" : 120,
            "height" : 180]
        ],
        ["title" : "baz",
          "size" : [
            "width" : 120,
            "height" : 180]
        ],
      ],
      "meta" : [
        "item-spacing" : 25.0,
        "line-spacing" : 10.0
      ]
    ]

    let component = Component(json)
    let spot = CarouselSpot(component: component)
    spot.setup(CGSize(width: 100, height: 100))

    // Test that spot height is equal to first item in the list
    XCTAssertEqual(spot.items.count, 3)
    XCTAssertEqual(spot.items[0].title, "foo")
    XCTAssertEqual(spot.items[1].title, "bar")
    XCTAssertEqual(spot.items[2].title, "baz")
    XCTAssertEqual(spot.items.first?.size.width, 120)
    XCTAssertEqual(spot.items.first?.size.height, 180)
    XCTAssertEqual(spot.render().frame.size.height, 180)

    // Check default value of `paginate`
    XCTAssertFalse(spot.paginate)

    // Check that header height gets added to the calculation
    spot.layout.headerReferenceSize.height = 20
    spot.setup(CGSize(width: 100, height: 100))
    XCTAssertEqual(spot.render().frame.size.height, 200)
  }

  func testCarouselSetupWithPagination() {
    let json: [String : AnyObject] = [
      "items" : [
        ["title" : "foo", "kind" : "carousel"],
        ["title" : "bar", "kind" : "carousel"],
        ["title" : "baz", "kind" : "carousel"],
        ["title" : "bazar", "kind" : "carousel"]
      ],
      "span" : 4.0,
      "meta" : [
        "item-spacing" : 25.0,
        "line-spacing" : 10.0,
        "dynamic-span" :  false,
        "paginate" : true,
      ]
    ]

    let component = Component(json)
    let spot = CarouselSpot(component: component)
    spot.render().layoutIfNeeded()

    // Check `span` mapping
    XCTAssertEqual(spot.component.span, 4)

    spot.setup(CGSize(width: 667, height: 225))
    spot.prepareItems()

    // Check `paginate` mapping
    XCTAssertTrue(spot.paginate)

    // Test that spot height is equal to first item in the list
    XCTAssertEqual(spot.items.count, 4)
    XCTAssertEqual(spot.items[0].title, "foo")
    XCTAssertEqual(spot.items[1].title, "bar")
    XCTAssertEqual(spot.items[2].title, "baz")
    XCTAssertEqual(spot.items[3].title, "bazar")
    XCTAssertEqual(spot.items[0].size.width, 103.5)
    XCTAssertEqual(spot.items[0].size.height, 225)
    XCTAssertEqual(spot.items[1].size.width, 103.5)
    XCTAssertEqual(spot.items[1].size.height, 225)
    XCTAssertEqual(spot.items[2].size.width, 103.5)
    XCTAssertEqual(spot.items[2].size.height, 225)
    XCTAssertEqual(spot.items[3].size.width, 103.5)
    XCTAssertEqual(spot.items[3].size.height, 225)
    XCTAssertEqual(spot.render().frame.size.height, 225)

    // Check that header height gets added to the calculation
    spot.layout.headerReferenceSize.height = 20
    spot.setup(CGSize(width: 100, height: 100))
    XCTAssertEqual(spot.render().frame.size.height, 245)
  }
}
