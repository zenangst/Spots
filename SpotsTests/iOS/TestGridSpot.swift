@testable import Spots
import Brick
import Foundation
import XCTest

class GridSpotTests: XCTestCase {

  var spot: GridSpot!
  var cachedSpot: GridSpot!

  override func setUp() {
    spot = GridSpot(component: Component(span: 1.0))
    cachedSpot = GridSpot(cacheKey: "cached-grid-spot")
    Helper.clearCache(for: cachedSpot.stateCache)
  }

  override func tearDown() {
    spot = nil
    cachedSpot = nil
  }

  func testConvenienceInitWithTitleAndKind() {
    let spot = GridSpot(title: "Spot")

    XCTAssertEqual(spot.component.title, "Spot")
    XCTAssertEqual(spot.component.kind, "grid")

    let customKindSpot = GridSpot(title: "Custom Spot", kind: "custom")
    XCTAssertEqual(customKindSpot.component.title, "Custom Spot")
    XCTAssertEqual(customKindSpot.component.kind, "custom")
  }

  func testConvenienceInitWithSectionInsets() {
    let component = Component(span: 1.0)
    let spot = GridSpot(component,
                       top: 5, left: 10, bottom: 5, right: 10, itemSpacing: 5)

    XCTAssertEqual(spot.layout.sectionInset, UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
    XCTAssertEqual(spot.layout.minimumInteritemSpacing, 5)
  }

  func testDictionaryRepresentation() {
    let component = Component(title: "GridSpot", kind: "row", span: 3, meta: ["headerHeight" : 44.0])
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
    let component = Component(title: "GridSpot", kind: "custom-grid", span: 1.0, items: [Item(title: "foo", kind: "custom-item-kind")])
    let rowSpot = GridSpot(component: component)
    let indexPath = IndexPath(row: 0, section: 0)

    XCTAssertEqual(rowSpot.identifier(at: indexPath), GridSpot.views.defaultIdentifier)

    GridSpot.views.defaultItem = Registry.Item.classType(GridSpotCell.self)
    XCTAssertEqual(rowSpot.identifier(at: indexPath),GridSpot.views.defaultIdentifier)

    GridSpot.views.defaultItem = Registry.Item.classType(GridSpotCell.self)
    XCTAssertEqual(rowSpot.identifier(at: indexPath),GridSpot.views.defaultIdentifier)

    GridSpot.views["custom-item-kind"] = Registry.Item.classType(GridSpotCell.self)
    XCTAssertEqual(rowSpot.identifier(at: indexPath), "custom-item-kind")

    GridSpot.views.storage.removeAll()
  }

  func testAppendItem() {
    let item = Item(title: "test")
    let spot = GridSpot(component: Component(span: 1.0))
    var exception: XCTestExpectation? = self.expectation(description: "Append item")
    spot.append(item) {
      XCTAssert(spot.component.items.first! == item)
      exception?.fulfill()
      exception = nil
    }
    waitForExpectations(timeout: 0.5, handler: nil)
  }

  func testAppendItems() {
    let items = [Item(title: "test"), Item(title: "test 2")]
    let spot = GridSpot(component: Component(span: 1.0))
    var exception: XCTestExpectation? = self.expectation(description: "Append items")
    spot.append(items) {
      XCTAssert(spot.component.items == items)
      exception?.fulfill()
      exception = nil
    }
    waitForExpectations(timeout: 0.5, handler: nil)
  }

  func testInsertItem() {
    let item = Item(title: "test")
    let spot = GridSpot(component: Component(span: 1.0))
    var exception: XCTestExpectation? = self.expectation(description: "Insert item")
    spot.insert(item, index: 0) {
      XCTAssert(spot.component.items.first! == item)
      exception?.fulfill()
      exception = nil
    }
    waitForExpectations(timeout: 0.5, handler: nil)
  }

  func testPrependItems() {
    let items = [Item(title: "test"), Item(title: "test 2")]
    let spot = GridSpot(component: Component(span: 1.0))
    var exception: XCTestExpectation? = self.expectation(description: "Prepend items")
    spot.prepend(items) {
      XCTAssert(spot.component.items == items)
      exception?.fulfill()
      exception = nil
    }
    waitForExpectations(timeout: 0.5, handler: nil)
  }

  func testSpotCollectionDelegate() {
    let items = [Item(title: "Test item")]
    let spot = GridSpot(component: Component(span: 0.0, items: items))
    spot.view.frame.size = CGSize(width: 100, height: 100)
    spot.view.layoutSubviews()

    let cell = spot.collectionView.cellForItem(at: IndexPath(item: 0, section: 0))
    XCTAssertEqual(cell?.frame.size, CGSize(width: 88, height: 88))
  }

  func testSpotCache() {
    let item = Item(title: "test")

    XCTAssertEqual(cachedSpot.component.items.count, 0)
    cachedSpot.append(item) { [weak self] in
      self?.cachedSpot.cache()
    }

    var exception: XCTestExpectation? = self.expectation(description: "Wait for cache")
    Dispatch.delay(for: 0.25) {
      let cachedSpot = GridSpot(cacheKey: self.cachedSpot.stateCache!.key)
      XCTAssertEqual(cachedSpot.component.items.count, 1)
      cachedSpot.stateCache?.clear()
      exception?.fulfill()
      exception = nil
    }
    waitForExpectations(timeout: 0.5, handler: nil)
  }
}
