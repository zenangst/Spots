@testable import Spots
import XCTest

class ComponentTests: XCTestCase {

  override func setUp() {
    Configuration.shared.views.defaultItem = nil
    Configuration.shared.register(view: HeaderView.self, identifier: "Header")
    Configuration.shared.register(view: TextView.self, identifier: "TextView")
    Configuration.shared.register(view: FooterView.self, identifier: "Footer")
    StateCache.removeAll()
  }

  func testDefaultValues() {
    Configuration.shared.defaultViewSize = .init(width: 0, height: 44)
    let items = [Item(title: "A"), Item(title: "B")]
    let model = ComponentModel(kind: .list, items: items)
    let component = Component(model: model)

    component.setup(with: CGSize(width: 100, height: 100))

    XCTAssertTrue(component.view is TableView)
    XCTAssertTrue(component.view.isEqual(component.tableView))
    XCTAssertEqual(component.model.items[0].size, CGSize(width: 100, height: 44))
    XCTAssertEqual(component.model.items[1].size, CGSize(width: 100, height: 44))
    XCTAssertEqual(component.view.frame.size, CGSize(width: 100, height: 100))

    /// tvOS adds 14 pixels to each item in a table view.
    /// So for tvOS, the calculation would look like this:
    /// let contentSize.height = item.reduce(0, { $0 + $1.item.size.height + 14 })
    #if os(tvOS)
      let expectedContentSizeHeight: CGFloat = 116
    #elseif os(iOS)
      let expectedContentSizeHeight: CGFloat = 88
    #endif
    XCTAssertEqual(component.view.contentSize, CGSize(width: 100, height: expectedContentSizeHeight))
  }

  func testComponentCache() {
    let item = Item(title: "test")
    let component = Component(cacheKey: "test-component-cache")

    XCTAssertEqual(component.model.items.count, 0)
    component.append(item) {
      component.cache()
    }

    let expectation = self.expectation(description: "Wait for cache")
    Dispatch.after(seconds: 2.5) {
      guard let cacheKey = component.stateCache?.key else {
        XCTFail()
        return
      }

      let cachedSpot = Component(cacheKey: cacheKey)
      XCTAssertEqual(cachedSpot.model.items[0].title, "test")
      XCTAssertEqual(cachedSpot.model.items.count, 1)
      cachedSpot.stateCache?.clear()
      expectation.fulfill()

      cachedSpot.stateCache?.clear()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }
}
