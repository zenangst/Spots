@testable import Spots
import Foundation
import XCTest

class GridComponentTests: XCTestCase {

  var component: GridComponent!
  var cachedComponent: GridComponent!

  override func setUp() {
    component = GridComponent(model: ComponentModel(span: 1.0))
    cachedComponent = GridComponent(cacheKey: "cached-grid-component")
    XCTAssertNotNil(cachedComponent.stateCache)
    cachedComponent.stateCache?.clear()
  }

  override func tearDown() {
    component = nil
    cachedComponent = nil
  }

  func testConvenienceInitWithSectionInsets() {
    let model = ComponentModel(span: 1.0)
    let component = GridComponent(model,
                       top: 5, left: 10, bottom: 5, right: 10, itemSpacing: 5)

    XCTAssertEqual(component.layout.sectionInset, UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
    XCTAssertEqual(component.layout.minimumInteritemSpacing, 5)
  }

  func testDictionaryRepresentation() {
    let model = ComponentModel(title: "GridComponent", kind: "row", span: 3, meta: ["headerHeight": 44.0])
    let component = GridComponent(model: model)
    XCTAssertEqual(model.dictionary["index"] as? Int, component.dictionary["index"] as? Int)
    XCTAssertEqual(model.dictionary["title"] as? String, component.dictionary["title"] as? String)
    XCTAssertEqual(model.dictionary["kind"] as? String, component.dictionary["kind"] as? String)
    XCTAssertEqual(model.dictionary["span"] as? Int, component.dictionary["span"] as? Int)
    XCTAssertEqual(
      (model.dictionary["meta"] as! [String : Any])["headerHeight"] as? CGFloat,
      (component.dictionary["meta"] as! [String : Any])["headerHeight"] as? CGFloat
    )
  }

  func testSafelyResolveKind() {
    let model = ComponentModel(title: "GridComponent", kind: "custom-grid", span: 1.0, items: [Item(title: "foo", kind: "custom-item-kind")])
    let rowComponent = GridComponent(model: model)
    let indexPath = IndexPath(row: 0, section: 0)

    XCTAssertEqual(rowComponent.identifier(at: indexPath), GridComponent.views.defaultIdentifier)

    GridComponent.views.defaultItem = Registry.Item.classType(GridComponentCell.self)
    XCTAssertEqual(rowComponent.identifier(at: indexPath), GridComponent.views.defaultIdentifier)

    GridComponent.views.defaultItem = Registry.Item.classType(GridComponentCell.self)
    XCTAssertEqual(rowComponent.identifier(at: indexPath), GridComponent.views.defaultIdentifier)

    GridComponent.views["custom-item-kind"] = Registry.Item.classType(GridComponentCell.self)
    XCTAssertEqual(rowComponent.identifier(at: indexPath), "custom-item-kind")

    GridComponent.views.storage.removeAll()
  }

  func testAppendItem() {
    let item = Item(title: "test")
    let component = GridComponent(model: ComponentModel(span: 1.0))
    let expectation = self.expectation(description: "Append item")
    component.append(item) {
      XCTAssert(component.model.items.first! == item)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendItems() {
    let items = [Item(title: "test"), Item(title: "test 2")]
    let component = GridComponent(model: ComponentModel(span: 1.0))
    let expectation = self.expectation(description: "Append items")
    component.append(items) {
      XCTAssert(component.model.items == items)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testInsertItem() {
    let item = Item(title: "test")
    let component = GridComponent(model: ComponentModel(span: 1.0))
    let expectation = self.expectation(description: "Insert item")
    component.insert(item, index: 0) {
      XCTAssert(component.model.items.first! == item)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testPrependItems() {
    let items = [Item(title: "test"), Item(title: "test 2")]
    let component = GridComponent(model: ComponentModel(span: 1.0))
    let expectation = self.expectation(description: "Prepend items")
    component.prepend(items) {
      XCTAssert(component.model.items == items)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testSpotCollectionDelegate() {
    let items = [Item(title: "Test item")]
    let component = GridComponent(model: ComponentModel(span: 0.0, items: items))
    component.view.frame.size = CGSize(width: 100, height: 100)
    component.view.layoutSubviews()

    let cell = component.collectionView.cellForItem(at: IndexPath(item: 0, section: 0))
    XCTAssertEqual(cell?.frame.size, CGSize(width: 88, height: 88))
  }

  func testSpotCache() {
    let item = Item(title: "test")

    XCTAssertEqual(cachedComponent.model.items.count, 0)
    cachedComponent.append(item) { [weak self] in
      self?.cachedComponent.cache()
    }

    let expectation = self.expectation(description: "Wait for cache")
    Dispatch.after(seconds: 0.25) {
      let cachedComponent = GridComponent(cacheKey: self.cachedComponent.stateCache!.key)
      XCTAssertEqual(cachedComponent.model.items.count, 1)
      cachedComponent.stateCache?.clear()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testSpotConfigurationClosure() {
    Configuration.register(view: TestView.self, identifier: "test-view")

    let items = [Item(title: "Item A", kind: "test-view"), Item(title: "Item B")]
    let component = GridComponent(model: ComponentModel(span: 0.0, items: items))
    component.setup(CGSize(width: 100, height: 100))
    component.layout(CGSize(width: 100, height: 100))
    component.view.layoutSubviews()

    var invokeCount = 0
    component.configure = { view in
      invokeCount += 1
    }
    XCTAssertEqual(invokeCount, 2)
  }
}
