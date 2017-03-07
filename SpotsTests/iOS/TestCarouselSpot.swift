@testable import Spots
import Foundation
import XCTest

class CarouselComponentTests: XCTestCase {

  var spot: CarouselComponent!
  var cachedSpot: CarouselComponent!

  override func setUp() {
    spot = CarouselComponent(model: ComponentModel(span: 1.0))
    cachedSpot = CarouselComponent(cacheKey: "cached-carousel-spot")
    XCTAssertNotNil(cachedSpot.stateCache)
    cachedSpot.stateCache?.clear()
  }

  override func tearDown() {
    spot = nil
    cachedSpot = nil
  }

  func testConvenienceInitWithSectionInsets() {
    let model = ComponentModel(span: 1.0)
    let spot = CarouselComponent(model,
                        top: 5, left: 10, bottom: 5, right: 10, itemSpacing: 5)

    XCTAssertEqual(spot.layout.sectionInset, UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
    XCTAssertEqual(spot.layout.minimumInteritemSpacing, 5)
  }

  func testDictionaryRepresentation() {
    let model = ComponentModel(title: "CarouselComponent", kind: "carousel", span: 3, meta: ["headerHeight": 44.0])
    let spot = CarouselComponent(model: model)
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
    let model = ComponentModel(title: "CarouselComponent", kind: "custom-carousel", span: 1.0, items: [Item(title: "foo", kind: "custom-item-kind")])
    let carouselSpot = CarouselComponent(model: model)
    let indexPath = IndexPath(row: 0, section: 0)

    XCTAssertEqual(carouselSpot.identifier(at: indexPath), CarouselComponent.views.defaultIdentifier)

    CarouselComponent.views.defaultItem = Registry.Item.classType(CarouselComponentCell.self)
    XCTAssertEqual(carouselSpot.identifier(at: indexPath), CarouselComponent.views.defaultIdentifier)

    CarouselComponent.views.defaultItem = Registry.Item.classType(CarouselComponentCell.self)
    XCTAssertEqual(carouselSpot.identifier(at: indexPath), CarouselComponent.views.defaultIdentifier)

    CarouselComponent.views["custom-item-kind"] = Registry.Item.classType(CarouselComponentCell.self)
    XCTAssertEqual(carouselSpot.identifier(at: indexPath), "custom-item-kind")

    CarouselComponent.views.purge()
    CarouselComponent.views.storage.removeAll()
  }

  func testMetaMapping() {
    var json: [String : Any] = [
      "meta": [
        "item-spacing": 25.0,
        "line-spacing": 10.0,
        "dynamic-span": true
      ]
    ]

    ComponentModel.legacyMapping = true

    var model = ComponentModel(json)
    var spot = CarouselComponent(model: model)
    spot.setup(CGSize(width: 100, height: 100))

    XCTAssertEqual(spot.layout.minimumInteritemSpacing, 25.0)
    XCTAssertEqual(spot.layout.minimumLineSpacing, 10.0)
    XCTAssertEqual(spot.dynamicSpan, true)

    json = [
      "meta": [
        "item-spacing": 12.5,
        "line-spacing": 7.5,
        "dynamic-span": false
      ]
    ]

    model = ComponentModel(json)
    spot = CarouselComponent(model: model)
    spot.setup(CGSize(width: 100, height: 100))

    XCTAssertEqual(spot.layout.minimumInteritemSpacing, 12.5)
    XCTAssertEqual(spot.layout.minimumLineSpacing, 7.5)
    XCTAssertEqual(spot.dynamicSpan, false)

    ComponentModel.legacyMapping = false
  }

  func testCarouselSetupWithSimpleStructure() {
    let json: [String : Any] = [
      "items": [
        ["title": "foo",
          "size": [
            "width": 120.0,
            "height": 180.0]
        ],
        ["title": "bar",
          "size": [
            "width": 120.0,
            "height": 180.0]
        ],
        ["title": "baz",
          "size": [
            "width": 120,
            "height": 180]
        ],
      ],
      "meta": [
        "item-spacing": 25.0,
        "line-spacing": 10.0
      ]
    ]

    let model = ComponentModel(json)
    let spot = CarouselComponent(model: model)
    spot.setup(CGSize(width: 100, height: 100))

    // Test that spot height is equal to first item in the list
    XCTAssertEqual(spot.items.count, 3)
    XCTAssertEqual(spot.items[0].title, "foo")
    XCTAssertEqual(spot.items[1].title, "bar")
    XCTAssertEqual(spot.items[2].title, "baz")
    XCTAssertEqual(spot.items.first?.size.width, 120)
    XCTAssertEqual(spot.items.first?.size.height, 180)
    XCTAssertEqual(spot.view.frame.size.height, 180)

    // Check default value of `paginate`
    XCTAssertFalse(spot.collectionView.isPagingEnabled)

    // Check that header height gets added to the calculation
    spot.layout.headerReferenceSize.height = 20
    spot.setup(CGSize(width: 100, height: 100))
    XCTAssertEqual(spot.view.frame.size.height, 200)
  }

  func testCarouselSetupWithPagination() {
    let json: [String : Any] = [
      "items": [
        ["title": "foo", "kind": "carousel"],
        ["title": "bar", "kind": "carousel"],
        ["title": "baz", "kind": "carousel"],
        ["title": "bazar", "kind": "carousel"]
      ],
      "interaction": Interaction(paginate: .page).dictionary,
      "layout": Layout(
        span: 4.0,
        dynamicSpan: false,
        pageIndicatorPlacement: .below
      ).dictionary
    ]

    let model = ComponentModel(json)
    let spot = CarouselComponent(model: model)
    let parentSize = CGSize(width: 667, height: 225)

    // Check `span` mapping
    XCTAssertEqual(spot.model.layout!.span, 4.0)

    spot.setup(parentSize)
    spot.layout(parentSize)
    spot.prepareItems()
    spot.view.layoutSubviews()

    let width = spot.view.bounds.width / 4

    // Test that spot height is equal to first item in the list
    XCTAssertEqual(spot.items.count, 4)
    XCTAssertEqual(spot.items[0].title, "foo")
    XCTAssertEqual(spot.items[1].title, "bar")
    XCTAssertEqual(spot.items[2].title, "baz")
    XCTAssertEqual(spot.items[3].title, "bazar")
    XCTAssertEqual(spot.items[0].size.width, width)
    XCTAssertEqual(spot.items[0].size.height, 88)
    XCTAssertEqual(spot.items[1].size.width, width)
    XCTAssertEqual(spot.items[1].size.height, 88)
    XCTAssertEqual(spot.items[2].size.width, width)
    XCTAssertEqual(spot.items[2].size.height, 88)
    XCTAssertEqual(spot.items[3].size.width, width)
    XCTAssertEqual(spot.items[3].size.height, 88)

    // Assert that height has been added for the page indicator
    XCTAssertEqual(spot.view.frame.size.height, 110)
    XCTAssertEqual(spot.view.contentSize.height, 110)

    // Check that header height gets added to the calculation
    spot.layout.headerReferenceSize.height = 20
    spot.setup(CGSize(width: 667, height: 225))
    spot.layout(CGSize(width: 667, height: 225))
    spot.view.layoutSubviews()
    XCTAssertEqual(spot.view.frame.size.height, 130)
    XCTAssertEqual(spot.view.contentSize.height, 130)
  }

  func testPageIndicatorOverlayPlacement() {
    let json: [String : Any] = [
      "items": [
        ["title": "foo", "kind": "carousel"],
        ["title": "bar", "kind": "carousel"],
        ["title": "baz", "kind": "carousel"],
        ["title": "bazar", "kind": "carousel"]
      ],
      "interaction": Interaction(paginate: .page).dictionary,
      "layout": Layout(
        span: 4.0,
        dynamicSpan: false,
        pageIndicatorPlacement: .overlay
      ).dictionary
    ]

    let model = ComponentModel(json)
    let spot = CarouselComponent(model: model)
    let parentSize = CGSize(width: 667, height: 225)

    spot.setup(parentSize)
    spot.layout(parentSize)
    spot.prepareItems()
    spot.view.layoutSubviews()

    // Sanity check, to make sure we have our page indicator in overlay mode
    XCTAssertEqual(model.layout!.pageIndicatorPlacement, .overlay)

    // Assert item layout (derived from preferred view size)
    XCTAssertEqual(spot.items[0].size.height, 88)
    XCTAssertEqual(spot.items[1].size.height, 88)
    XCTAssertEqual(spot.items[2].size.height, 88)
    XCTAssertEqual(spot.items[3].size.height, 88)

    // Assert that no height has been added for a page indicator
    XCTAssertEqual(spot.view.frame.height, 88)
  }

  func testPaginatedCarouselSnapping() {
    class CollectionViewMock: UICollectionView {
      var itemSize = CGSize.zero

      override func indexPathForItem(at point: CGPoint) -> IndexPath? {
        return IndexPath(item: Int(point.x / itemSize.width), section: 0)
      }
    }

    let json: [String : Any] = [
      "items": [
        [
          "title": "title",
          "kind": "carousel",
          "size": [
            "width": 200.0,
            "height": 100.0
          ]
        ],
        [
          "title": "title",
          "kind": "carousel",
          "size": [
            "width": 200.0,
            "height": 100.0
          ]
        ],
        [
          "title": "title",
          "kind": "carousel",
          "size": [
            "width": 200.0,
            "height": 100.0
          ]
        ],
        [
          "title": "title",
          "kind": "carousel",
          "size": [
            "width": 200.0,
            "height": 100.0
          ]
        ]
      ],
      "interaction": Interaction(paginate: .item).dictionary,
      "layout": Layout(
        span: 0,
        dynamicSpan: false,
        pageIndicatorPlacement: .below,
        itemSpacing: 0
      ).dictionary
    ]

    let layout = CollectionLayout()
    let collectionView = CollectionViewMock(frame: .zero, collectionViewLayout: layout)
    collectionView.itemSize = CGSize(width: 200, height: 100)

    let model = ComponentModel(json)
    let spot = CarouselComponent(model: model, collectionView: collectionView, layout: layout)
    let parentSize = CGSize(width: 300, height: 100)

    spot.setup(parentSize)
    spot.layout(parentSize)
    spot.prepareItems()
    spot.view.layoutSubviews()

    // Make sure our mocked item size is correct
    XCTAssertEqual(collectionView.itemSize, spot.items[0].size)

    // When scrolling, make sure the closest item is centered
    var originalPoint = CGPoint(x: 350, y: 0)
    let targetContentOffset = UnsafeMutablePointer(mutating: &originalPoint)
    collectionView.delegate!.scrollViewWillEndDragging!(collectionView, withVelocity: .zero, targetContentOffset: targetContentOffset)
    XCTAssertEqual(targetContentOffset.pointee.x, 350)

    // When scrolling back to origin, no centering should occur
    targetContentOffset.pointee.x = 0
    collectionView.delegate!.scrollViewWillEndDragging!(collectionView, withVelocity: .zero, targetContentOffset: targetContentOffset)
    XCTAssertEqual(targetContentOffset.pointee.x, 0)

    // Make sure an out of bounds content offset is not manipulated
    targetContentOffset.pointee.x = 100000
    targetContentOffset.pointee.y = 100000
    collectionView.delegate!.scrollViewWillEndDragging!(collectionView, withVelocity: .zero, targetContentOffset: targetContentOffset)
    XCTAssertEqual(targetContentOffset.pointee.x, 100000)
    XCTAssertEqual(targetContentOffset.pointee.y, 100000)
  }

  func testAppendItem() {
    let item = Item(title: "test")
    let spot = CarouselComponent(model: ComponentModel(span: 1))
    let expectation = self.expectation(description: "Append item")
    spot.append(item) {
      XCTAssert(spot.model.items.first! == item)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendItems() {
    let items = [Item(title: "test"), Item(title: "test 2")]
    let spot = CarouselComponent(model: ComponentModel(span: 1))
    let expectation = self.expectation(description: "Append items")
    spot.append(items) {
      XCTAssert(spot.model.items == items)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testInsertItem() {
    let item = Item(title: "test")
    let spot = CarouselComponent(model: ComponentModel(span: 1))
    let expectation = self.expectation(description: "Insert item")
    spot.insert(item, index: 0) {
      XCTAssert(spot.model.items.first! == item)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testPrependItems() {
    let items = [Item(title: "test"), Item(title: "test 2")]
    let spot = CarouselComponent(model: ComponentModel(span: 1))
    let expectation = self.expectation(description: "Prepend items")
    spot.prepend(items) {
      XCTAssert(spot.model.items == items)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testSpotCache() {
    let item = Item(title: "test")

    XCTAssertEqual(cachedSpot.model.items.count, 0)
    cachedSpot.append(item) {
      self.cachedSpot.cache()
    }

    let expectation = self.expectation(description: "Wait for cache")
    Dispatch.after(seconds: 0.25) { [weak self] in
      guard let weakSelf = self else { return }
      let cachedSpot = CarouselComponent(cacheKey: weakSelf.cachedSpot.stateCache!.key)
      XCTAssertEqual(cachedSpot.model.items.count, 1)
      cachedSpot.stateCache?.clear()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testSpotConfigurationClosure() {
    Configuration.register(view: TestView.self, identifier: "test-view")

    let items = [Item(title: "Item A", kind: "test-view"), Item(title: "Item B")]
    let spot = CarouselComponent(model: ComponentModel(span: 0.0, items: items))
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
