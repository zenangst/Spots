@testable import Spots
import Foundation
import XCTest
import Brick

class ControllerTests : XCTestCase {

  func testSpotAtIndex() {
    let component = Component(title: "Component")
    let listSpot = ListSpot(component: component)
    let spotController = Controller(spot: listSpot)

    XCTAssertEqual(spotController.spot as? ListSpot, listSpot)
  }

  func testUpdateSpotAtIndex() {
    let component = Component(title: "Component")
    let listSpot = ListSpot(component: component)
    let spotController = Controller(spot: listSpot)
    let items = [Item(title: "item1")]

    spotController.update { spot in
      spot.component.items = items
    }

    XCTAssert(spotController.spot!.component.items == items)
  }

  func testAppendItemInListSpot() {
    let component = Component(title: "Component", kind: "list")
    let listSpot = ListSpot(component: component)
    let spotController = Controller(spot: listSpot)

    XCTAssert(spotController.spot!.component.items.count == 0)

    let item = Item(title: "title1", kind: "list")
    spotController.append(item, spotIndex: 0)

    XCTAssert(spotController.spot!.component.items.count == 1)

    if let testItem = spotController.spot!.component.items.first {
      XCTAssert(testItem == item)
    }

    // Test appending item without kind
    let exception = self.expectation(description: "Test append item")
    spotController.append(Item(title: "title2"), spotIndex: 0) {
      XCTAssert(spotController.spot!.component.items.count == 2)
      XCTAssertEqual(spotController.spot!.component.items[1].title, "title2")
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testAppendItemsInListSpot() {
    let component = Component(title: "Component", kind: "list")
    let listSpot = ListSpot(component: component)
    let spotController = Controller(spot: listSpot)

    let items = [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list")
    ]
    spotController.append(items, spotIndex: 0)

    XCTAssert(spotController.spot!.component.items.count > 0)
    XCTAssert(spotController.spot!.component.items == items)

    // Test appending items without kind
    let exception = self.expectation(description: "Test append items")
    spotController.append([
      Item(title: "title3"),
      Item(title: "title4")
    ], spotIndex: 0) {
      XCTAssertEqual(spotController.spot!.component.items.count, 4)
      XCTAssertEqual(spotController.spot!.component.items[2].title, "title3")
      XCTAssertEqual(spotController.spot!.component.items[3].title, "title4")
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testPrependItemsInListSpot() {
    let component = Component(title: "Component", kind: "list")
    let listSpot = ListSpot(component: component)
    let spotController = Controller(spot: listSpot)

    let items = [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list")
    ]
    spotController.prepend(items, spotIndex: 0)

    XCTAssertEqual(spotController.spot!.component.items.count, 2)
    XCTAssert(spotController.spot!.component.items == items)

    let exception = self.expectation(description: "Test prepend items")
    spotController.prepend([
      Item(title: "title3"),
      Item(title: "title4")
    ], spotIndex: 0) {
      XCTAssertEqual(spotController.spot!.component.items[0].title, "title3")
      XCTAssertEqual(spotController.spot!.component.items[1].title, "title4")
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testDeleteItemInListSpot() {
    let component = Component(title: "Component", kind: "list", items: [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list")
      ])
    let initialListSpot = ListSpot(component: component)

    let spotController = Controller(spot: initialListSpot)

    let firstItem = spotController.spot!.component.items.first

    XCTAssertEqual(firstItem?.title, "title1")
    XCTAssertEqual(firstItem?.index, 0)

    let exception = self.expectation(description: "Test delete item")
    let listSpot = (spotController.spot as! ListSpot)
    listSpot.delete(component.items.first!) {
      let lastItem = spotController.spot!.component.items.first

      XCTAssertNotEqual(lastItem?.title, "title1")
      XCTAssertEqual(lastItem?.index, 1)
      XCTAssertEqual(lastItem?.title, "title2")
      XCTAssertEqual(spotController.spot!.component.items.count, 1)
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testAppendItemInGridSpot() {
    let component = Component(title: "Component", kind: "grid")
    let listSpot = ListSpot(component: component)
    let spotController = Controller(spot: listSpot)

    XCTAssert(spotController.spot!.component.items.count == 0)

    let item = Item(title: "title1", kind: "grid")
    spotController.append(item, spotIndex: 0)

    XCTAssert(spotController.spot!.component.items.count == 1)

    if let testItem = spotController.spot!.component.items.first {
      XCTAssert(testItem == item)
    }

    // Test appending item without kind
    let exception = self.expectation(description: "Test append item")
    spotController.append(Item(title: "title2"), spotIndex: 0) {
      XCTAssert(spotController.spot!.component.items.count == 2)
      XCTAssertEqual(spotController.spot!.component.items[1].title, "title2")
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testAppendItemsInGridSpot() {
    let component = Component(title: "Component", kind: "grid")
    let listSpot = ListSpot(component: component)
    let spotController = Controller(spot: listSpot)

    let items = [
      Item(title: "title1", kind: "grid"),
      Item(title: "title2", kind: "grid")
    ]
    spotController.append(items, spotIndex: 0)

    XCTAssert(spotController.spot!.component.items.count > 0)
    XCTAssert(spotController.spot!.component.items == items)

    // Test appending items without kind
    let exception = self.expectation(description: "Test append items")
    spotController.append([
      Item(title: "title3"),
      Item(title: "title4")
    ], spotIndex: 0) {
      XCTAssertEqual(spotController.spot!.component.items.count, 4)
      XCTAssertEqual(spotController.spot!.component.items[2].title, "title3")
      XCTAssertEqual(spotController.spot!.component.items[3].title, "title4")
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testPrependItemsInGridSpot() {
    let component = Component(title: "Component", kind: "grid")
    let listSpot = ListSpot(component: component)
    let spotController = Controller(spot: listSpot)

    let items = [
      Item(title: "title1", kind: "grid"),
      Item(title: "title2", kind: "grid")
    ]
    spotController.prepend(items, spotIndex: 0)

    XCTAssertEqual(spotController.spot!.component.items.count, 2)
    XCTAssert(spotController.spot!.component.items == items)

    let exception = self.expectation(description: "Test prepend items")
    spotController.prepend([
      Item(title: "title3"),
      Item(title: "title4")
    ], spotIndex: 0) {
      XCTAssertEqual(spotController.spot!.component.items[0].title, "title3")
      XCTAssertEqual(spotController.spot!.component.items[1].title, "title4")
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testDeleteItemInGridSpot() {
    let component = Component(title: "Component", kind: "grid", items: [
      Item(title: "title1", kind: "grid"),
      Item(title: "title2", kind: "grid")
      ])
    let initialListSpot = ListSpot(component: component)

    let spotController = Controller(spot: initialListSpot)

    let firstItem = spotController.spot!.component.items.first

    XCTAssertEqual(firstItem?.title, "title1")
    XCTAssertEqual(firstItem?.index, 0)

    let exception = self.expectation(description: "Test delete item")
    let listSpot = (spotController.spot as! ListSpot)
    listSpot.delete(component.items.first!) {
      let lastItem = spotController.spot!.component.items.first

      XCTAssertNotEqual(lastItem?.title, "title1")
      XCTAssertEqual(lastItem?.index, 1)
      XCTAssertEqual(lastItem?.title, "title2")
      XCTAssertEqual(spotController.spot!.component.items.count, 1)
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testAppendItemInCarouselSpot() {
    let component = Component(title: "Component", kind: "carousel")
    let listSpot = ListSpot(component: component)
    let spotController = Controller(spot: listSpot)

    XCTAssert(spotController.spot!.component.items.count == 0)

    let item = Item(title: "title1", kind: "carousel")
    spotController.append(item, spotIndex: 0)

    XCTAssert(spotController.spot!.component.items.count == 1)

    if let testItem = spotController.spot!.component.items.first {
      XCTAssert(testItem == item)
    }

    // Test appending item without kind
    let exception = self.expectation(description: "Test append item")
    spotController.append(Item(title: "title2"), spotIndex: 0) {
      XCTAssert(spotController.spot!.component.items.count == 2)
      XCTAssertEqual(spotController.spot!.component.items[1].title, "title2")
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testAppendItemsInCarouselSpot() {
    let component = Component(title: "Component", kind: "carousel")
    let listSpot = ListSpot(component: component)
    let spotController = Controller(spot: listSpot)

    let items = [
      Item(title: "title1", kind: "carousel"),
      Item(title: "title2", kind: "carousel")
    ]
    spotController.append(items, spotIndex: 0)

    XCTAssert(spotController.spot!.component.items.count > 0)
    XCTAssert(spotController.spot!.component.items == items)

    // Test appending items without kind
    let exception = self.expectation(description: "Test append items")
    spotController.append([
      Item(title: "title3"),
      Item(title: "title4")
    ], spotIndex: 0) {
      XCTAssertEqual(spotController.spot!.component.items.count, 4)
      XCTAssertEqual(spotController.spot!.component.items[2].title, "title3")
      XCTAssertEqual(spotController.spot!.component.items[3].title, "title4")
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testPrependItemsInCarouselSpot() {
    let component = Component(title: "Component", kind: "carousel")
    let listSpot = ListSpot(component: component)
    let spotController = Controller(spot: listSpot)

    let items = [
      Item(title: "title1", kind: "carousel"),
      Item(title: "title2", kind: "carousel")
    ]
    spotController.prepend(items, spotIndex: 0)

    XCTAssertEqual(spotController.spot!.component.items.count, 2)
    XCTAssert(spotController.spot!.component.items == items)

    let exception = self.expectation(description: "Test prepend items")
    spotController.prepend([
      Item(title: "title3"),
      Item(title: "title4")
    ], spotIndex: 0) {
      XCTAssertEqual(spotController.spot!.component.items[0].title, "title3")
      XCTAssertEqual(spotController.spot!.component.items[1].title, "title4")
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testDeleteItemInCarouselSpot() {
    let component = Component(title: "Component", kind: "carousel", items: [
      Item(title: "title1", kind: "carousel"),
      Item(title: "title2", kind: "carousel")
      ])
    let initialListSpot = ListSpot(component: component)

    let spotController = Controller(spot: initialListSpot)

    let firstItem = spotController.spot!.component.items.first

    XCTAssertEqual(firstItem?.title, "title1")
    XCTAssertEqual(firstItem?.index, 0)

    let exception = self.expectation(description: "Test delete item")
    let listSpot = (spotController.spot as! ListSpot)
    listSpot.delete(component.items.first!) {
      let lastItem = spotController.spot!.component.items.first

      XCTAssertNotEqual(lastItem?.title, "title1")
      XCTAssertEqual(lastItem?.index, 1)
      XCTAssertEqual(lastItem?.title, "title2")
      XCTAssertEqual(spotController.spot!.component.items.count, 1)
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testComputedPropertiesOnSpotable() {
    let component = Component(title: "Component", kind: "list", items: [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list")
      ])
    let spot = ListSpot(component: component)

    XCTAssert(spot.items == component.items)

    let newItems = [Item(title: "title3", kind: "list")]
    spot.items = newItems
    XCTAssertFalse(spot.items == component.items)
    XCTAssert(spot.items == newItems)
  }

  func testFindAndFilterSpotWithClosure() {
    let listSpot = ListSpot(component: Component(title: "ListSpot"))
    let listSpot2 = ListSpot(component: Component(title: "ListSpot2"))
    let gridSpot = GridSpot(component: Component(title: "GridSpot", items: [Item(title: "Item")]))
    let spotController = Controller(spots: [listSpot, listSpot2, gridSpot])

    XCTAssertNotNil(spotController.resolve(spot: { $1.component.title == "ListSpot" }))
    XCTAssertNotNil(spotController.resolve(spot: { $1.component.title == "GridSpot" }))
    XCTAssertNotNil(spotController.resolve(spot: { $1 is Listable }))
    XCTAssertNotNil(spotController.resolve(spot: { $1 is Gridable }))
    XCTAssertNotNil(spotController.resolve(spot: { $1.items.filter{ $0.title == "Item" }.first != nil }))
    XCTAssertEqual(spotController.resolve(spot: { $0.0 == 0 })?.component.title, "ListSpot")
    XCTAssertEqual(spotController.resolve(spot: { $0.0 == 1 })?.component.title, "ListSpot2")
    XCTAssertEqual(spotController.resolve(spot: { $0.0 == 2 })?.component.title, "GridSpot")

    XCTAssert(spotController.filter(spots: { $0 is Listable }).count == 2)
  }

  func testJSONInitialiser() {
    let spot = ListSpot()
    spot.items = [Item(title: "First item")]
    let sourceController = Controller(spot: spot)
    let jsonController = Controller([
      "components" : [
        ["kind" : "list",
          "items" : [
            ["title" : "First item"]
          ]
        ]
      ]
      ])

    XCTAssert(sourceController.spot!.component == jsonController.spot!.component)
  }

  func testJSONReload() {
    let initialJSON = [
      "components" : [
        ["kind" : "list",
          "items" : [
            ["title" : "First list item"]
          ]
        ]
      ]
    ]
    let jsonController = Controller(initialJSON)

    XCTAssert(jsonController.spot!.component.kind == "list")
    XCTAssert(jsonController.spot!.component.items.count == 1)
    XCTAssert(jsonController.spot!.component.items.first?.title == "First list item")

    let updateJSON = [
      "components" : [
        ["kind" : "grid",
          "items" : [
            ["title" : "First grid item"],
            ["title" : "Second grid item"]
          ]
        ]
      ]
    ]

    let exception = self.expectation(description: "Reload with JSON")
    jsonController.reload(updateJSON) {
      XCTAssert(jsonController.spot!.component.kind == "grid")
      XCTAssert(jsonController.spot!.component.items.count == 2)
      XCTAssert(jsonController.spot!.component.items.first?.title == "First grid item")
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testDictionaryOnController() {
    let initialJSON = [
      "components" : [
        ["kind" : "list",
          "items" : [
            ["title" : "First list item"]
          ]
        ]
      ]
    ]
    let firstController = Controller(initialJSON)
    let secondController = Controller(firstController.dictionary)

    XCTAssertTrue(firstController.spots.first!.component == secondController.spots.first!.component)
  }

  func testReloadIfNeededWithComponents() {
    let initialJSON: [String : Any] = [
      "components" : [
        ["kind" : "list",
          "items" : [
            ["title" : "First list item"]
          ]
        ],
        ["kind" : "list",
          "items" : [
            ["title" : "First list item"]
          ]
        ]
      ]
    ]

    let newJSON: [String : Any] = [
      "components" : [
        ["kind" : "list",
          "items" : [
            ["title" : "First list item 2"],
            [
              "kind" : "composite",
              "items" : [
                ["kind" : "grid",
                  "items" : [
                    ["title" : "First list item"]
                  ]
                ]
              ]
            ]
          ]
        ],
        ["kind" : "grid",
          "items" : [
            ["title" : "First list item"]
          ]
        ]
      ]
    ]

    let controller = Controller(initialJSON)
    XCTAssertTrue(controller.spots[0] is ListSpot)
    XCTAssertEqual(controller.spots[0].items.first?.title, "First list item")
    XCTAssertEqual(controller.spots[1].items.first?.title, "First list item")
    XCTAssertTrue(controller.spots[1] is ListSpot)
    XCTAssertTrue(controller.spots.count == 2)
    XCTAssertTrue(controller.compositeSpots.count == 0)

    let exception = self.expectation(description: "Reload multiple times with JSON (if needed)")
    
    controller.reloadIfNeeded(newJSON) {
      XCTAssertEqual(controller.spots.count, 2)
      XCTAssertTrue(controller.spots[0] is ListSpot)
      XCTAssertTrue(controller.spots[1] is GridSpot)
      XCTAssertEqual(controller.spots[0].items.first?.title, "First list item 2")
      XCTAssertEqual(controller.spots[1].items.first?.title, "First list item")

      XCTAssertEqual(controller.spots[0].items[1].kind, "composite")
      XCTAssertTrue(controller.compositeSpots.count == 1)

      controller.reloadIfNeeded(initialJSON) {
        XCTAssertTrue(controller.spots[0] is ListSpot)
        XCTAssertEqual(controller.spots[0].items.first?.title, "First list item")
        XCTAssertEqual(controller.spots[1].items.first?.title, "First list item")
        XCTAssertTrue(controller.spots[1] is ListSpot)
        XCTAssertTrue(controller.spots.count == 2)
        XCTAssertTrue(controller.compositeSpots.count == 0)
        exception.fulfill()
      }
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }
}
