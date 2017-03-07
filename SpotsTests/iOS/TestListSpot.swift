@testable import Spots
import Foundation
import XCTest

class ListComponentTests: XCTestCase {

  var cachedSpot: ListComponent!

  override func setUp() {
    cachedSpot = ListComponent(cacheKey: "cached-list-spot")
    XCTAssertNotNil(cachedSpot.stateCache)
    cachedSpot.stateCache?.clear()
  }

  override func tearDown() {
    cachedSpot = nil
  }

  func testDictionaryRepresentation() {
    let model = ComponentModel(title: "ListComponent", kind: "list", span: 3, meta: ["headerHeight": 44.0])
    let component = ListComponent(model: model)
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
    let model = ComponentModel(title: "ListComponent", kind: "custom-list", span: 1.0, items: [Item(title: "foo", kind: "custom-item-kind")])
    let listSpot = ListComponent(model: model)
    let indexPath = IndexPath(row: 0, section: 0)

    XCTAssertEqual(listSpot.identifier(at: indexPath), ListComponent.views.defaultIdentifier)

    ListComponent.views.defaultItem = Registry.Item.classType(ListComponentCell.self)
    XCTAssertEqual(listSpot.identifier(at: indexPath), ListComponent.views.defaultIdentifier)

    ListComponent.views.defaultItem = Registry.Item.classType(ListComponentCell.self)
    XCTAssertEqual(listSpot.identifier(at: indexPath), ListComponent.views.defaultIdentifier)

    ListComponent.views["custom-item-kind"] = Registry.Item.classType(ListComponentCell.self)
    XCTAssertEqual(listSpot.identifier(at: indexPath), "custom-item-kind")

    ListComponent.views.storage.removeAll()
  }

  func testSpotCache() {
    let item = Item(title: "test")

    XCTAssertEqual(cachedSpot.model.items.count, 0)
    cachedSpot.append(item) {
      self.cachedSpot.cache()
    }

    let expectation = self.expectation(description: "Wait for cache")
    Dispatch.after(seconds: 0.25) {
      let cachedSpot = ListComponent(cacheKey: self.cachedSpot.stateCache!.key)
      XCTAssertEqual(cachedSpot.model.items.count, 1)
      cachedSpot.stateCache?.clear()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testSpotConfigurationClosure() {
    Configuration.register(view: TestView.self, identifier: "test-view")

    let items = [Item(title: "Item A", kind: "test-view"), Item(title: "Item B")]
    let component = ListComponent(model: ComponentModel(span: 0.0, items: items))
    component.setup(CGSize(width: 100, height: 100))
    component.layout(CGSize(width: 100, height: 100))
    component.view.layoutSubviews()

    var invokeCount = 0
    component.configure = { view in
      invokeCount += 1
    }
    XCTAssertEqual(invokeCount, 2)
  }

  func testAccessibilityForDefaultCells() {
    let cell = ListComponentCell(style: .default, reuseIdentifier: "reuse")
    var item = Item(title: "Title", subtitle: "Subtitle")
    cell.configure(&item)

    XCTAssertTrue(cell.isAccessibilityElement)
    XCTAssertEqual(cell.accessibilityIdentifier, "Title")
    XCTAssertEqual(cell.accessibilityLabel, "Title.Subtitle")

    // If disabling accessibility, properties should not be set when reconfiguring the cell
    cell.isAccessibilityElement = false
    cell.accessibilityIdentifier = nil
    cell.accessibilityLabel = nil
    cell.configure(&item)

    XCTAssertFalse(cell.isAccessibilityElement)
    XCTAssertNil(cell.accessibilityIdentifier)
    XCTAssertNil(cell.accessibilityLabel)
  }
}
