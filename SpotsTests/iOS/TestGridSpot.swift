@testable import Spots
import Foundation
import XCTest

class GridComponentTests: XCTestCase {

  var spot: GridComponent!
  var cachedSpot: GridComponent!

  override func setUp() {
    spot = GridComponent(model: ComponentModel(span: 1.0))
    cachedSpot = GridComponent(cacheKey: "cached-grid-spot")
    XCTAssertNotNil(cachedSpot.stateCache)
    cachedSpot.stateCache?.clear()
  }

  override func tearDown() {
    spot = nil
    cachedSpot = nil
  }

  func testConvenienceInitWithSectionInsets() {
    let model = ComponentModel(span: 1.0)
    let spot = GridComponent(model,
                       top: 5, left: 10, bottom: 5, right: 10, itemSpacing: 5)

    XCTAssertEqual(spot.layout.sectionInset, UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
    XCTAssertEqual(spot.layout.minimumInteritemSpacing, 5)
  }

  func testDictionaryRepresentation() {
    let model = ComponentModel(title: "GridComponent", kind: "row", span: 3, meta: ["headerHeight": 44.0])
    let spot = GridComponent(model: model)
    XCTAssertEqual(model.dictionary["index"] as? Int, spot.dictionary["index"] as? Int)
    XCTAssertEqual(model.dictionary["title"] as? String, spot.dictionary["title"] as? String)
    XCTAssertEqual(model.dictionary["kind"] as? String, spot.dictionary["kind"] as? String)
    XCTAssertEqual(model.dictionary["span"] as? Int, spot.dictionary["span"] as? Int)
    XCTAssertEqual(
      (model.dictionary["meta"] as! [String : Any])["headerHeight"] as? CGFloat,
      (spot.dictionary["meta"] as! [String : Any])["headerHeight"] as? CGFloat
    )
  }

  func testSafelyResolveKind() {
    let model = ComponentModel(title: "GridComponent", kind: "custom-grid", span: 1.0, items: [Item(title: "foo", kind: "custom-item-kind")])
    let rowSpot = GridComponent(model: model)
    let indexPath = IndexPath(row: 0, section: 0)

    XCTAssertEqual(rowSpot.identifier(at: indexPath), GridComponent.views.defaultIdentifier)

    GridComponent.views.defaultItem = Registry.Item.classType(GridComponentCell.self)
    XCTAssertEqual(rowSpot.identifier(at: indexPath), GridComponent.views.defaultIdentifier)

    GridComponent.views.defaultItem = Registry.Item.classType(GridComponentCell.self)
    XCTAssertEqual(rowSpot.identifier(at: indexPath), GridComponent.views.defaultIdentifier)

    GridComponent.views["custom-item-kind"] = Registry.Item.classType(GridComponentCell.self)
    XCTAssertEqual(rowSpot.identifier(at: indexPath), "custom-item-kind")

    GridComponent.views.storage.removeAll()
  }

  func testAppendItem() {
    let item = Item(title: "test")
    let spot = GridComponent(model: ComponentModel(span: 1.0))
    let expectation = self.expectation(description: "Append item")
    spot.append(item) {
      XCTAssert(spot.model.items.first! == item)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendItems() {
    let items = [Item(title: "test"), Item(title: "test 2")]
    let spot = GridComponent(model: ComponentModel(span: 1.0))
    let expectation = self.expectation(description: "Append items")
    spot.append(items) {
      XCTAssert(spot.model.items == items)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testInsertItem() {
    let item = Item(title: "test")
    let spot = GridComponent(model: ComponentModel(span: 1.0))
    let expectation = self.expectation(description: "Insert item")
    spot.insert(item, index: 0) {
      XCTAssert(spot.model.items.first! == item)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testPrependItems() {
    let items = [Item(title: "test"), Item(title: "test 2")]
    let spot = GridComponent(model: ComponentModel(span: 1.0))
    let expectation = self.expectation(description: "Prepend items")
    spot.prepend(items) {
      XCTAssert(spot.model.items == items)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testSpotCollectionDelegate() {
    let items = [Item(title: "Test item")]
    let spot = GridComponent(model: ComponentModel(span: 0.0, items: items))
    spot.view.frame.size = CGSize(width: 100, height: 100)
    spot.view.layoutSubviews()

    let cell = spot.collectionView.cellForItem(at: IndexPath(item: 0, section: 0))
    XCTAssertEqual(cell?.frame.size, CGSize(width: 88, height: 88))
  }

  func testSpotCache() {
    let item = Item(title: "test")

    XCTAssertEqual(cachedSpot.model.items.count, 0)
    cachedSpot.append(item) { [weak self] in
      self?.cachedSpot.cache()
    }

    let expectation = self.expectation(description: "Wait for cache")
    Dispatch.after(seconds: 0.25) {
      let cachedSpot = GridComponent(cacheKey: self.cachedSpot.stateCache!.key)
      XCTAssertEqual(cachedSpot.model.items.count, 1)
      cachedSpot.stateCache?.clear()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testSpotConfigurationClosure() {
    Configuration.register(view: TestView.self, identifier: "test-view")

    let items = [Item(title: "Item A", kind: "test-view"), Item(title: "Item B")]
    let spot = GridComponent(model: ComponentModel(span: 0.0, items: items))
    spot.setup(CGSize(width: 100, height: 100))
    spot.layout(CGSize(width: 100, height: 100))
    spot.view.layoutSubviews()

    var invokeCount = 0
    spot.configure = { view in
      invokeCount += 1
    }
    XCTAssertEqual(invokeCount, 2)
  }
}
