@testable import Spots
import Brick
import Foundation
import XCTest

class CarouselSpotTests: XCTestCase {

  var spot: CarouselSpot!
  var cachedSpot: CarouselSpot!

  override func setUp() {
    spot = CarouselSpot(component: Component(span: 1.0))
    cachedSpot = CarouselSpot(cacheKey: "cached-carousel-spot")
    Helper.clearCache(for: cachedSpot.stateCache)
  }

  override func tearDown() {
    spot = nil
    cachedSpot = nil
  }

  func testConvenienceInitWithSectionInsets() {
    let component = Component(span: 1.0)
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
      (component.dictionary["meta"] as! [String : Any])["headerHeight"] as? CGFloat,
      (spot.dictionary["meta"] as! [String : Any])["headerHeight"] as? CGFloat
    )
  }

  func testSafelyResolveKind() {
    let component = Component(title: "CarouselSpot", kind: "custom-carousel", span: 1.0, items: [Item(title: "foo", kind: "custom-item-kind")])
    let carouselSpot = CarouselSpot(component: component)
    let indexPath = IndexPath(row: 0, section: 0)

    XCTAssertEqual(carouselSpot.identifier(at: indexPath), CarouselSpot.views.defaultIdentifier)

    CarouselSpot.views.defaultItem = Registry.Item.classType(CarouselSpotCell.self)
    XCTAssertEqual(carouselSpot.identifier(at: indexPath),CarouselSpot.views.defaultIdentifier)

    CarouselSpot.views.defaultItem = Registry.Item.classType(CarouselSpotCell.self)
    XCTAssertEqual(carouselSpot.identifier(at: indexPath),CarouselSpot.views.defaultIdentifier)

    CarouselSpot.views["custom-item-kind"] = Registry.Item.classType(CarouselSpotCell.self)
    XCTAssertEqual(carouselSpot.identifier(at: indexPath), "custom-item-kind")

    CarouselSpot.views.purge()
    CarouselSpot.views.storage.removeAll()
  }

  func testMetaMapping() {
    var json: [String : Any] = [
      "meta" : [
        "item-spacing" : 25.0,
        "line-spacing" : 10.0,
        "dynamic-span" :  true
      ]
    ]

    Component.legacyMapping = true

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

    Component.legacyMapping = false
  }

  func testCarouselSetupWithSimpleStructure() {
    let json: [String : Any] = [
      "items" : [
        ["title" : "foo",
          "size" : [
            "width" : 120.0,
            "height" : 180.0]
        ],
        ["title" : "bar",
          "size" : [
            "width" : 120.0,
            "height" : 180.0]
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
    XCTAssertEqual(spot.view.frame.size.height, 180)

    // Check default value of `paginate`
    XCTAssertFalse(spot.collectionView.isPagingEnabled)

    // Check that header height gets added to the calculation
    spot.layout.headerReferenceSize.height = 20
    spot.setup(CGSize(width: 100, height: 100))
    XCTAssertEqual(spot.view.frame.size.height, 200)
  }

  func testCarouselSetupWithPagination() {
    let json: [String : Any] = [
      "items" : [
        ["title" : "foo", "kind" : "carousel"],
        ["title" : "bar", "kind" : "carousel"],
        ["title" : "baz", "kind" : "carousel"],
        ["title" : "bazar", "kind" : "carousel"]
      ],
      "interaction" : Interaction(paginate: .page).dictionary,
      "layout" : Layout(
        span: 4.0,
        dynamicSpan: false,
        pageIndicator: true
        ).dictionary
    ]

    let component = Component(json)
    let spot = CarouselSpot(component: component)
    let parentSize = CGSize(width: 667, height: 225)

    // Check `span` mapping
    XCTAssertEqual(spot.component.layout!.span, 4.0)

    spot.setup(parentSize)
    spot.layout(parentSize)
    spot.prepareItems()
    spot.view.layoutSubviews()

    // Check `paginate` mapping
    XCTAssertTrue(spot.collectionView.isPagingEnabled)

    let width = spot.view.bounds.width / 4

    // Test that spot height is equal to first item in the list
    XCTAssertEqual(spot.items.count, 4)
    XCTAssertEqual(spot.items[0].title, "foo")
    XCTAssertEqual(spot.items[1].title, "bar")
    XCTAssertEqual(spot.items[2].title, "baz")
    XCTAssertEqual(spot.items[3].title, "bazar")
    XCTAssertEqual(spot.items[0].size.width, width)
    XCTAssertEqual(spot.items[0].size.height, 88)
    XCTAssertEqual(spot.items[1].size.width, width)
    XCTAssertEqual(spot.items[1].size.height, 88)
    XCTAssertEqual(spot.items[2].size.width, width)
    XCTAssertEqual(spot.items[2].size.height, 88)
    XCTAssertEqual(spot.items[3].size.width, width)
    XCTAssertEqual(spot.items[3].size.height, 88)
    XCTAssertEqual(spot.view.frame.size.height, 110)
    XCTAssertEqual(spot.view.contentSize.height, 110)

    // Check that header height gets added to the calculation
    spot.layout.headerReferenceSize.height = 20
    spot.setup(CGSize(width: 667, height: 225))
    spot.layout(CGSize(width: 667, height: 225))
    XCTAssertEqual(spot.view.frame.size.height, 130)
    XCTAssertEqual(spot.view.contentSize.height, 130)
  }

  func testAppendItem() {
    let item = Item(title: "test")
    let spot = CarouselSpot(component: Component(span: 1))
    var exception: XCTestExpectation? = self.expectation(description: "Append item")
    spot.append(item) {
      XCTAssert(spot.component.items.first! == item)
      exception?.fulfill()
      exception = nil
    }
    waitForExpectations(timeout: 1.0, handler: nil)
  }

  func testAppendItems() {
    let items = [Item(title: "test"), Item(title: "test 2")]
    let spot = CarouselSpot(component: Component(span: 1))
    var exception: XCTestExpectation? = self.expectation(description: "Append items")
    spot.append(items) {
      XCTAssert(spot.component.items == items)
      exception?.fulfill()
      exception = nil
    }
    waitForExpectations(timeout: 1.0, handler: nil)
  }

  func testInsertItem() {
    let item = Item(title: "test")
    let spot = CarouselSpot(component: Component(span: 1))
    var exception: XCTestExpectation? = self.expectation(description: "Insert item")
    spot.insert(item, index: 0) {
      XCTAssert(spot.component.items.first! == item)
      exception?.fulfill()
      exception = nil
    }
    waitForExpectations(timeout: 1.0, handler: nil)
  }

  func testPrependItems() {
    let items = [Item(title: "test"), Item(title: "test 2")]
    let spot = CarouselSpot(component: Component(span: 1))
    var exception: XCTestExpectation? = self.expectation(description: "Prepend items")
    spot.prepend(items) {
      XCTAssert(spot.component.items == items)
      exception?.fulfill()
      exception = nil
    }
    waitForExpectations(timeout: 1.0, handler: nil)
  }

  func testSpotCache() {
    let item = Item(title: "test")

    XCTAssertEqual(cachedSpot.component.items.count, 0)
    cachedSpot.append(item) {
      self.cachedSpot.cache()
    }

    var exception: XCTestExpectation? = self.expectation(description: "Wait for cache")
    Dispatch.after(seconds: 0.25) { [weak self] in
      guard let weakSelf = self else { return }
      let cachedSpot = CarouselSpot(cacheKey: weakSelf.cachedSpot.stateCache!.key)
      XCTAssertEqual(cachedSpot.component.items.count, 1)
      cachedSpot.stateCache?.clear()
      exception?.fulfill()
      exception = nil
    }
    waitForExpectations(timeout: 0.5, handler: nil)
  }
}
