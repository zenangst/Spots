@testable import Spots
import XCTest

class ComponentMacOSTests: XCTestCase {

  override func setUp() {
    Configuration.views.defaultItem = nil
    Configuration.register(view: HeaderView.self, identifier: "Header")
    Configuration.register(view: TextView.self, identifier: "TextView")
    Configuration.register(view: FooterView.self, identifier: "Footer")
  }
  
  class ComponentTestView: View, ItemConfigurable {
    func configure(with item: Item) {}
    func computeSize(for item: Item, containerSize: CGSize) -> CGSize {
      return CGSize(width: 100, height: 100)
    }
  }

  func testComponentComputedHeightConstraint() {
    let identifier = "testComponentComputedHeightConstraint"
    Configuration.register(view: ComponentTestView.self, identifier: identifier)
    let items = [
      Item(kind: identifier),
      Item(kind: identifier),
      Item(kind: identifier),
      Item(kind: identifier),
      Item(kind: identifier),
      Item(kind: identifier),
      ]
    let model = ComponentModel(kind: .grid, items: items)
    let component = Component(model: model)
    let controller = SpotsController(components: [component])
    controller.prepareController()
    let expectation = self.expectation(description: "Expect comonent to have the same height as the enclosing scroll view.")

    component.updateHeight {
      XCTAssertEqual(controller.scrollView.frame.size.height, component.view.frame.size.height)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10.0)
  }

  func testDefaultValuesWithList() {
    Configuration.views.purge()
    Configuration.defaultComponentKind = .list
    Configuration.defaultViewSize = .init(width: 0, height: PlatformDefaults.defaultHeight)
    let items = [Item(title: "A"), Item(title: "B")]
    let model = ComponentModel(items: items)
    let component = Component(model: model)

    component.setup(with: CGSize(width: 100, height: 100))

    XCTAssertNotNil(component.view)
    XCTAssertNotNil(component.tableView)
    XCTAssertEqual(component.model.items[0].size, CGSize(width: 100, height: 88))
    XCTAssertEqual(component.model.items[1].size, CGSize(width: 100, height: 88))
    XCTAssertEqual(component.view.frame.size, CGSize(width: 100, height: 180))
    let expectedContentSizeHeight: CGFloat = 180
    XCTAssertEqual(component.view.contentSize, CGSize(width: 100, height: expectedContentSizeHeight))
  }

  func testSpotCache() {
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

  func testHybridListComponentWithHeaderAndFooter() {
    let model = ComponentModel(
      header: Item(title: "Header", kind: "Header"),
      footer: Item(title: "Footer", kind: "Footer"),
      kind: .list,
      items: [
        Item(title: "A"),
        Item(title: "B"),
        Item(title: "C"),
        Item(title: "D")
      ]
    )
    let component = Component(model: model)
    component.setup(with: CGSize(width: 100, height: 100))

    XCTAssertEqual(component.view.frame.size, CGSize(width: 100, height: 460))
    XCTAssertEqual(component.view.contentSize, CGSize(width: 100, height: 460))
  }

  func testHybridGridComponentWithHeaderAndFooter() {
    let model = ComponentModel(
      header: Item(title: "Header", kind: "Header"),
      footer: Item(title: "Footer", kind: "Footer"),
      kind: .grid,
      items: [
        Item(title: "A", kind: "TextView"),
        Item(title: "B", kind: "TextView"),
        Item(title: "C", kind: "TextView"),
        Item(title: "D", kind: "TextView")
      ]
    )
    let component = Component(model: model)
    component.setup(with: CGSize(width: 100, height: 100))

    XCTAssertEqual(component.collectionView?.collectionViewLayout?.collectionViewContentSize, CGSize(width: 100, height: 300))
    XCTAssertEqual(component.view.frame.size, CGSize(width: 100, height: 100))
    XCTAssertEqual(component.view.contentSize, CGSize(width: 100, height: 100))
  }

  func testHybridCarouselComponentWithHeaderAndFooter() {
    let model = ComponentModel(
      header: Item(title: "Header", kind: "Header"),
      footer: Item(title: "Footer", kind: "Footer"),
      kind: .carousel,
      items: [
        Item(title: "A", kind: "TextView"),
        Item(title: "B", kind: "TextView"),
        Item(title: "C", kind: "TextView"),
        Item(title: "D", kind: "TextView")
      ]
    )
    let component = Component(model: model)
    component.setup(with: CGSize(width: 100, height: 100))

    // Items are 50 in height, headers and footer share the same height of 50
    // hence the total height being 150.
    XCTAssertEqual(component.view.frame.size, CGSize(width: 100, height: 100))
    XCTAssertEqual(component.view.contentSize, CGSize(width: 400, height: 100))
  }
}
