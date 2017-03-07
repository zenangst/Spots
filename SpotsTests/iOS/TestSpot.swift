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
    let spot = Spot(model: model)

    spot.setup(CGSize(width: 100, height: 100))

    XCTAssertTrue(spot.view is TableView)
    XCTAssertTrue(spot.view.isEqual(spot.tableView))
    XCTAssertEqual(spot.items[0].size, CGSize(width: 100, height: 44))
    XCTAssertEqual(spot.items[1].size, CGSize(width: 100, height: 44))
    XCTAssertEqual(spot.view.frame.size, CGSize(width: 100, height: 100))

    /// tvOS adds 14 pixels to each item in a table view.
    /// So for tvOS, the calculation would look like this:
    /// let contentSize.height = item.reduce(0, { $0 + $1.item.size.height + 14 })
    #if os(tvOS)
      let expectedContentSizeHeight: CGFloat = 116
    #elseif os(iOS)
      let expectedContentSizeHeight: CGFloat = 88
    #endif
    XCTAssertEqual(spot.view.contentSize, CGSize(width: 100, height: expectedContentSizeHeight))
  }

  func testSpotCache() {
    let item = Item(title: "test")
    let spot = Spot(cacheKey: "test-spot-cache")

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

      let cachedSpot = Spot(cacheKey: cacheKey)
      XCTAssertEqual(cachedSpot.model.items[0].title, "test")
      XCTAssertEqual(cachedSpot.model.items.count, 1)
      cachedSpot.stateCache?.clear()
      expectation.fulfill()

      cachedSpot.stateCache?.clear()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testCompareHybridListSpotWithCoreType() {
    let items = [Item(title: "A"), Item(title: "B")]
    let model = ComponentModel(kind: ComponentModel.Kind.list.string, items: items, hybrid: true)
    let listComponentModel = ComponentModel(kind: ComponentModel.Kind.list.string, items: items)
    let spot = Spot(model: model)
    let listSpot = ListSpot(model: listComponentModel)

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

  func testCompareHybridGridSpotWithCoreType() {
    let items = [Item(title: "A"), Item(title: "B")]
    let model = ComponentModel(kind: ComponentModel.Kind.grid.string, items: items, hybrid: true)
    let gridComponentModel = ComponentModel(kind: ComponentModel.Kind.grid.string, items: items)
    let spot = Spot(model: model)
    let gridSpot = GridSpot(model: gridComponentModel)

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

  func testCompareHybridCarouselSpotWithCoreType() {
    let items = [Item(title: "A"), Item(title: "B")]
    let model = ComponentModel(kind: ComponentModel.Kind.carousel.string, items: items, hybrid: true)
    let carouselComponentModel = ComponentModel(kind: ComponentModel.Kind.carousel.string, items: items)
    let spot = Spot(model: model)
    let carouselSpot = CarouselSpot(model: carouselComponentModel)

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

  func testHybridListSpotWithHeaderAndFooter() {
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
    let spot = Spot(model: model)
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

  func testHybridCarouselSpotWithHeaderAndFooter() {
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
    let spot = Spot(model: model)
    spot.setup(CGSize(width: 100, height: 100))

    XCTAssertEqual(spot.view.frame.size, CGSize(width: 100, height: 188))
    XCTAssertEqual(spot.view.contentSize, CGSize(width: 352, height: 188))
  }
}
