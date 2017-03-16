@testable import Spots
import XCTest

class TestSpot: XCTestCase {

  override func setUp() {
    Configuration.views.storage = [:]
    Configuration.views.defaultItem = nil
    Configuration.register(view: HeaderView.self, identifier: "Header")
    Configuration.register(view: TextView.self, identifier: "TextView")
    Configuration.register(view: FooterView.self, identifier: "Footer")
  }

  func testDefaultValues() {
    let items = [Item(title: "A"), Item(title: "B")]
    let model = ComponentModel(items: items, hybrid: true)
    let component = Component(model: model)

    component.setup(CGSize(width: 100, height: 100))

    XCTAssertTrue(component.view is TableView)
    XCTAssertTrue(component.view.isEqual(component.tableView))
    XCTAssertEqual(component.items[0].size, CGSize(width: 100, height: 44))
    XCTAssertEqual(component.items[1].size, CGSize(width: 100, height: 44))
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

  func testCompareHybridListComponentWithCoreType() {
    let items = [Item(title: "A"), Item(title: "B")]
    let model = ComponentModel(kind: ComponentModel.Kind.list.string, items: items, hybrid: true)
    let listComponentModel = ComponentModel(kind: ComponentModel.Kind.list.string, items: items)
    let component = Component(model: model)
    let listComponent = ListComponent(model: listComponentModel)

    XCTAssertTrue(type(of: component.view) == type(of: listComponent.view))

    component.setup(CGSize(width: 100, height: 100))
    listComponent.setup(CGSize(width: 100, height: 100))
    listComponent.layout(CGSize(width: 100, height: 100))
    listComponent.view.layoutSubviews()

    XCTAssertEqual(component.model.interaction.scrollDirection, listComponent.model.interaction.scrollDirection)
    XCTAssertEqual(component.items[0].size, listComponent.items[0].size)
    XCTAssertEqual(component.items[1].size, listComponent.items[0].size)
    XCTAssertEqual(component.sizeForItem(at: IndexPath(item: 0, section: 0)), listComponent.sizeForItem(at: IndexPath(item: 0, section: 0)))
    XCTAssertEqual(component.sizeForItem(at: IndexPath(item: 1, section: 0)), listComponent.sizeForItem(at: IndexPath(item: 1, section: 0)))
    XCTAssertEqual(component.view.frame, listComponent.view.frame)
    XCTAssertEqual(component.view.contentSize, listComponent.view.contentSize)
  }

  func testCompareHybridGridComponentWithCoreType() {
    let items = [Item(title: "A"), Item(title: "B")]
    let model = ComponentModel(kind: ComponentModel.Kind.grid.string, items: items, hybrid: true)
    let gridComponentModel = ComponentModel(kind: ComponentModel.Kind.grid.string, items: items)
    let component = Component(model: model)
    let gridComponent = GridComponent(model: gridComponentModel)

    XCTAssertTrue(type(of: component.view) == type(of: gridComponent.view))

    component.setup(CGSize(width: 100, height: 100))
    gridComponent.setup(CGSize(width: 100, height: 100))
    gridComponent.layout(CGSize(width: 100, height: 100))
    gridComponent.view.layoutSubviews()

    XCTAssertEqual(component.model.interaction.scrollDirection, gridComponent.model.interaction.scrollDirection)
    XCTAssertEqual(component.items[0].size, gridComponent.items[0].size)
    XCTAssertEqual(component.items[1].size, gridComponent.items[0].size)
    XCTAssertEqual(component.sizeForItem(at: IndexPath(item: 0, section: 0)), gridComponent.sizeForItem(at: IndexPath(item: 0, section: 0)))
    XCTAssertEqual(component.sizeForItem(at: IndexPath(item: 1, section: 0)), gridComponent.sizeForItem(at: IndexPath(item: 1, section: 0)))
    XCTAssertEqual(component.view.frame, gridComponent.view.frame)
    XCTAssertEqual(component.view.contentSize, gridComponent.view.contentSize)
  }

  func testCompareHybridCarouselComponentWithCoreType() {
    let items = [Item(title: "A"), Item(title: "B")]
    let model = ComponentModel(kind: ComponentModel.Kind.carousel.string, items: items, hybrid: true)
    let carouselComponentModel = ComponentModel(kind: ComponentModel.Kind.carousel.string, items: items)
    let component = Component(model: model)
    let carouselComponent = CarouselComponent(model: carouselComponentModel)

    XCTAssertTrue(type(of: component.view) == type(of: carouselComponent.view))

    component.setup(CGSize(width: 100, height: 100))
    carouselComponent.setup(CGSize(width: 100, height: 100))
    carouselComponent.layout(CGSize(width: 100, height: 100))
    carouselComponent.view.layoutSubviews()

    XCTAssertEqual(component.model.interaction.scrollDirection, carouselComponent.model.interaction.scrollDirection)
    XCTAssertEqual(component.items[0].size, carouselComponent.items[0].size)
    XCTAssertEqual(component.items[1].size, carouselComponent.items[0].size)
    XCTAssertEqual(component.sizeForItem(at: IndexPath(item: 0, section: 0)), carouselComponent.sizeForItem(at: IndexPath(item: 0, section: 0)))
    XCTAssertEqual(component.sizeForItem(at: IndexPath(item: 1, section: 0)), carouselComponent.sizeForItem(at: IndexPath(item: 1, section: 0)))
    XCTAssertEqual(component.view.frame, carouselComponent.view.frame)
    XCTAssertEqual(component.view.contentSize, carouselComponent.view.contentSize)
  }

  func testHybridListComponentWithHeaderAndFooter() {
    let model = ComponentModel(
      header: Item(kind: "Header"),
      footer: Item(kind: "Footer"),
      kind: ComponentModel.Kind.list.string,
      items: [
        Item(title: "A"),
        Item(title: "B"),
        Item(title: "C"),
        Item(title: "D")
      ],
      hybrid: true
    )
    let component = Component(model: model)
    component.setup(CGSize(width: 100, height: 100))

    XCTAssertEqual(component.view.frame.size, CGSize(width: 100, height: 100))

    /// tvOS adds 14 pixels to each item in a table view.
    /// So for tvOS, the calculation would look like this:
    /// let contentSize.height = item.reduce(0, { $0 + $1.item.size.height + 14 })
    #if os(tvOS)
      let expectedContentSizeHeight: CGFloat = 332
    #elseif os(iOS)
      let expectedContentSizeHeight: CGFloat = 276
    #endif
    XCTAssertEqual(component.view.contentSize, CGSize(width: 100, height: expectedContentSizeHeight))
  }

  func testHybridCarouselComponentWithHeaderAndFooter() {
    let model = ComponentModel(
      header: Item(kind: "Header"),
      footer: Item(kind: "Footer"),
      kind: ComponentModel.Kind.carousel.string,
      items: [
        Item(title: "A"),
        Item(title: "B"),
        Item(title: "C"),
        Item(title: "D")
      ],
      hybrid: true
    )
    let component = Component(model: model)
    component.setup(CGSize(width: 100, height: 100))

    XCTAssertEqual(component.view.frame.size, CGSize(width: 100, height: 188))
    XCTAssertEqual(component.view.contentSize, CGSize(width: 352, height: 188))
  }
}
