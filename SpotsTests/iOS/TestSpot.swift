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
    let spot = Component(cacheKey: "test-spot-cache")

    XCTAssertEqual(spot.model.items.count, 0)
    spot.append(item) {
      spot.cache()
    }

    let expectation = self.expectation(description: "Wait for cache")
    Dispatch.after(seconds: 2.5) {
      guard let cacheKey = spot.stateCache?.key else {
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
    let spot = Component(model: model)
    let listSpot = ListComponent(model: listComponentModel)

    XCTAssertTrue(type(of: spot.view) == type(of: listSpot.view))

    spot.setup(CGSize(width: 100, height: 100))
    listSpot.setup(CGSize(width: 100, height: 100))
    listSpot.layout(CGSize(width: 100, height: 100))
    listSpot.view.layoutSubviews()

    XCTAssertEqual(spot.model.interaction.scrollDirection, listSpot.model.interaction.scrollDirection)
    XCTAssertEqual(spot.items[0].size, listSpot.items[0].size)
    XCTAssertEqual(spot.items[1].size, listSpot.items[0].size)
    XCTAssertEqual(spot.sizeForItem(at: IndexPath(item: 0, section: 0)), listSpot.sizeForItem(at: IndexPath(item: 0, section: 0)))
    XCTAssertEqual(spot.sizeForItem(at: IndexPath(item: 1, section: 0)), listSpot.sizeForItem(at: IndexPath(item: 1, section: 0)))
    XCTAssertEqual(spot.view.frame, listSpot.view.frame)
    XCTAssertEqual(spot.view.contentSize, listSpot.view.contentSize)
  }

  func testCompareHybridGridComponentWithCoreType() {
    let items = [Item(title: "A"), Item(title: "B")]
    let model = ComponentModel(kind: ComponentModel.Kind.grid.string, items: items, hybrid: true)
    let gridComponentModel = ComponentModel(kind: ComponentModel.Kind.grid.string, items: items)
    let spot = Component(model: model)
    let gridSpot = GridComponent(model: gridComponentModel)

    XCTAssertTrue(type(of: spot.view) == type(of: gridSpot.view))

    spot.setup(CGSize(width: 100, height: 100))
    gridSpot.setup(CGSize(width: 100, height: 100))
    gridSpot.layout(CGSize(width: 100, height: 100))
    gridSpot.view.layoutSubviews()

    XCTAssertEqual(spot.model.interaction.scrollDirection, gridSpot.model.interaction.scrollDirection)
    XCTAssertEqual(spot.items[0].size, gridSpot.items[0].size)
    XCTAssertEqual(spot.items[1].size, gridSpot.items[0].size)
    XCTAssertEqual(spot.sizeForItem(at: IndexPath(item: 0, section: 0)), gridSpot.sizeForItem(at: IndexPath(item: 0, section: 0)))
    XCTAssertEqual(spot.sizeForItem(at: IndexPath(item: 1, section: 0)), gridSpot.sizeForItem(at: IndexPath(item: 1, section: 0)))
    XCTAssertEqual(spot.view.frame, gridSpot.view.frame)
    XCTAssertEqual(spot.view.contentSize, gridSpot.view.contentSize)
  }

  func testCompareHybridCarouselComponentWithCoreType() {
    let items = [Item(title: "A"), Item(title: "B")]
    let model = ComponentModel(kind: ComponentModel.Kind.carousel.string, items: items, hybrid: true)
    let carouselComponentModel = ComponentModel(kind: ComponentModel.Kind.carousel.string, items: items)
    let spot = Component(model: model)
    let carouselSpot = CarouselComponent(model: carouselComponentModel)

    XCTAssertTrue(type(of: spot.view) == type(of: carouselSpot.view))

    spot.setup(CGSize(width: 100, height: 100))
    carouselSpot.setup(CGSize(width: 100, height: 100))
    carouselSpot.layout(CGSize(width: 100, height: 100))
    carouselSpot.view.layoutSubviews()

    XCTAssertEqual(spot.model.interaction.scrollDirection, carouselSpot.model.interaction.scrollDirection)
    XCTAssertEqual(spot.items[0].size, carouselSpot.items[0].size)
    XCTAssertEqual(spot.items[1].size, carouselSpot.items[0].size)
    XCTAssertEqual(spot.sizeForItem(at: IndexPath(item: 0, section: 0)), carouselSpot.sizeForItem(at: IndexPath(item: 0, section: 0)))
    XCTAssertEqual(spot.sizeForItem(at: IndexPath(item: 1, section: 0)), carouselSpot.sizeForItem(at: IndexPath(item: 1, section: 0)))
    XCTAssertEqual(spot.view.frame, carouselSpot.view.frame)
    XCTAssertEqual(spot.view.contentSize, carouselSpot.view.contentSize)
  }

  func testHybridListComponentWithHeaderAndFooter() {
    let model = ComponentModel(
      header: "Header",
      footer: "Footer",
      kind: ComponentModel.Kind.list.string,
      items: [
        Item(title: "A"),
        Item(title: "B"),
        Item(title: "C"),
        Item(title: "D")
      ],
      hybrid: true
    )
    let spot = Component(model: model)
    spot.setup(CGSize(width: 100, height: 100))

    XCTAssertEqual(spot.view.frame.size, CGSize(width: 100, height: 100))

    /// tvOS adds 14 pixels to each item in a table view.
    /// So for tvOS, the calculation would look like this:
    /// let contentSize.height = item.reduce(0, { $0 + $1.item.size.height + 14 })
    #if os(tvOS)
      let expectedContentSizeHeight: CGFloat = 332
    #elseif os(iOS)
      let expectedContentSizeHeight: CGFloat = 276
    #endif
    XCTAssertEqual(spot.view.contentSize, CGSize(width: 100, height: expectedContentSizeHeight))
  }

  func testHybridCarouselComponentWithHeaderAndFooter() {
    let model = ComponentModel(
      header: "Header",
      footer: "Footer",
      kind: ComponentModel.Kind.carousel.string,
      items: [
        Item(title: "A"),
        Item(title: "B"),
        Item(title: "C"),
        Item(title: "D")
      ],
      hybrid: true
    )
    let spot = Component(model: model)
    spot.setup(CGSize(width: 100, height: 100))

    XCTAssertEqual(spot.view.frame.size, CGSize(width: 100, height: 188))
    XCTAssertEqual(spot.view.contentSize, CGSize(width: 352, height: 188))
  }
}
