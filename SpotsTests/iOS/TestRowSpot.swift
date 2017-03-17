@testable import Spots
import Foundation
import XCTest

class RowSpotTests: XCTestCase {

  var component: RowComponent!
  var cachedSpot: RowComponent!

  override func setUp() {
    component = RowComponent(model: ComponentModel(span: 1))
    cachedSpot = RowComponent(cacheKey: "cached-row-component")
    XCTAssertNotNil(cachedSpot.stateCache)
    cachedSpot.stateCache?.clear()
  }

  override func tearDown() {
    component = nil
    cachedSpot = nil
  }

  func testConvenienceInitWithSectionInsets() {
    let layout = Layout(itemSpacing: 5, inset: Inset(top: 5, left: 10, bottom: 5, right: 10))
    let model = ComponentModel(kind: "row", layout: layout, span: 1)
    let component = RowComponent(model: model)

    if let collectionView = component.collectionView {
      XCTFail("Unable to resolve collection view layout.")
      return
    }

    /// TODO: Fix this
    //XCTAssertEqual(collectionView.sectionInset, UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
    //XCTAssertEqual(collectionViewLayout.minimumInteritemSpacing, 5)
  }

  func testDictionaryRepresentation() {
    let model = ComponentModel(title: "RowComponent", kind: "row", span: 3, meta: ["headerHeight": 44.0])
    let component = RowComponent(model: model)
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
    let model = ComponentModel(title: "RowComponent", kind: "custom-grid", span: 1, items: [Item(title: "foo", kind: "custom-item-kind")])
    let rowComponent = RowComponent(model: model)
    let indexPath = IndexPath(row: 0, section: 0)

    XCTAssertEqual(rowComponent.identifier(at: indexPath), RowComponent.views.defaultIdentifier)

    RowComponent.views.defaultItem = Registry.Item.classType(GridComponentCell.self)
    XCTAssertEqual(rowComponent.identifier(at: indexPath), RowComponent.views.defaultIdentifier)

    RowComponent.views.defaultItem = Registry.Item.classType(GridComponentCell.self)
    XCTAssertEqual(rowComponent.identifier(at: indexPath), RowComponent.views.defaultIdentifier)

    RowComponent.views["custom-item-kind"] = Registry.Item.classType(GridComponentCell.self)
    XCTAssertEqual(rowComponent.identifier(at: indexPath), "custom-item-kind")

    RowComponent.views.storage.removeAll()
  }

  func testAppendItem() {
    let item = Item(title: "test")
    let component = RowComponent(model: ComponentModel(span: 1))
    let expectation = self.expectation(description: "Append item")
    component.append(item) {
      XCTAssert(component.model.items.first! == item)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendItems() {
    let items = [Item(title: "test"), Item(title: "test 2")]
    let component = RowComponent(model: ComponentModel(span: 1))
    let expectation = self.expectation(description: "Append items")
    component.append(items) {
      XCTAssert(component.model.items == items)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testInsertItem() {
    let item = Item(title: "test")
    let component = RowComponent(model: ComponentModel(span: 1))
    let expectation = self.expectation(description: "Insert item")
    component.insert(item, index: 0) {
      XCTAssert(component.model.items.first! == item)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testPrependItems() {
    let items = [Item(title: "test"), Item(title: "test 2")]
    let component = RowComponent(model: ComponentModel(span: 1))
    let expectation = self.expectation(description: "Prepend items")
    component.prepend(items) {
      XCTAssert(component.model.items == items)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testSpotCollectionDelegate() {
    let items = [Item(title: "Test item")]
    let component = RowComponent(model: ComponentModel(span: 1, items: items))
    component.view.frame.size = CGSize(width: 100, height: 100)
    component.view.layoutSubviews()

    guard let collectionView = component.collectionView else {
      XCTFail("Unable to resolve collection view.")
      return
    }

    let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0))
    XCTAssertEqual(cell?.frame.size, CGSize(width: UIScreen.main.bounds.width, height: 44))
  }

  func testSpotCache() {
    let item = Item(title: "test")

    XCTAssertEqual(cachedSpot.model.items.count, 0)
    cachedSpot.append(item) {
      self.cachedSpot.cache()
    }

    let expectation = self.expectation(description: "Wait for cache")
    Dispatch.after(seconds: 0.25) {
      let cachedSpot = RowComponent(cacheKey: self.cachedSpot.stateCache!.key)
      XCTAssertEqual(cachedSpot.model.items.count, 1)
      cachedSpot.stateCache?.clear()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testSpotConfigurationClosure() {
    Configuration.register(view: TestView.self, identifier: "test-view")

    let items = [Item(title: "Item A", kind: "test-view"), Item(title: "Item B")]
    let component = RowComponent(model: ComponentModel(span: 0.0, items: items))
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
