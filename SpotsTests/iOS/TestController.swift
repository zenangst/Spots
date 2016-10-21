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
      XCTAssertEqual(lastItem?.index, 0)
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
      XCTAssertEqual(lastItem?.index, 0)
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
      XCTAssertEqual(lastItem?.index, 0)
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

  func testReloadIfNeededWithJSON() {
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
      XCTAssertEqual(controller.compositeSpots.count, 1)

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

  func testReloadWithComponents() {
    let initialComponents = [
      Component(
        kind: "list",
        items: [
          Item(title: "Fullname", subtitle: "Job title", kind: "image"),
          Item(title: "Follow", kind: "toggle", meta: ["dynamic-height" : true]),
          Item(title: "First name", subtitle: "Input first name",kind: "info"),
          Item(title: "Last name", subtitle: "Input last name",kind: "info"),
          Item(title: "Twitter", subtitle: "@twitter",kind: "info"),
          Item(title: "", subtitle: "Biography", kind: "core", meta: ["dynamic-height" : true])
        ]
      )
    ]

    let newComponents = [
      Component(
        kind: "list",
        items: [
          Item(title: "Fullname", subtitle: "Job title", text: "Bot", kind: "image"),
          Item(title: "Follow", kind: "toggle", meta: ["dynamic-height" : true]),
          Item(title: "First name", subtitle: "Input first name", text: "John", kind: "info"),
          Item(title: "Last name", subtitle: "Input last name", text: "Hyperseed", kind: "info"),
          Item(title: "Twitter", subtitle: "@johnhyperseed",kind: "info"),
          Item(subtitle: "Biography", text: "John Hyperseed is a bot", kind: "core", meta: ["dynamic-height" : true])
        ]
      )
    ]

    let spots = initialComponents.map { Factory.resolve(component: $0) }

    /// Validate factory process
    XCTAssertEqual(spots.count, 1)
    XCTAssert(spots.first is ListSpot)

    /// Test first item in the first component of the first spot
    XCTAssertEqual(spots.first!.component.kind, "list")
    XCTAssertEqual(spots.first!.component.items[0].title, "Fullname")
    XCTAssertEqual(spots.first!.component.items[0].subtitle, "Job title")
    XCTAssertEqual(spots.first!.component.items[0].kind, "image")
    XCTAssertEqual(spots.first!.component.items[0].size, CGSize(width: UIScreen.main.bounds.width, height: 44))

    /// Validate setting up a controller
    let controller = Controller(spots: spots)
    XCTAssertEqual(controller.spots.count, 1)

    /// Test first item in the first component of the first spot inside of the controller
    XCTAssertEqual(controller.spots.first!.component.kind, spots.first!.component.kind)
    XCTAssertEqual(controller.spots.first!.component.items[0].title, spots.first!.component.items[0].title)
    XCTAssertEqual(controller.spots.first!.component.items[0].subtitle, spots.first!.component.items[0].subtitle)
    XCTAssertEqual(controller.spots.first!.component.items[0].kind, spots.first!.component.items[0].kind)
    XCTAssertEqual(controller.spots.first!.component.items[0].size, spots.first!.component.items[0].size)

    XCTAssertTrue(initialComponents !== newComponents)
    XCTAssertEqual(initialComponents.count, newComponents.count)

    let oldComponents: [Component] = controller.spots.map { $0.component }

    let changes = controller.generateChanges(from: newComponents, and: oldComponents)
    XCTAssertEqual(changes.count, 1)
    XCTAssertEqual(changes.first, .items)

    /// Test what changed on the items
    let newItems = newComponents.first!.items
    var oldItems = controller.spots.first!.items
    var diff = Item.evaluate(newItems, oldModels: oldItems)
    XCTAssertEqual(diff![0], .text)
    XCTAssertEqual(diff![1], .none)
    XCTAssertEqual(diff![2], .text)
    XCTAssertEqual(diff![3], .text)
    XCTAssertEqual(diff![4], .subtitle)
    XCTAssertEqual(diff![5], .text)
    
    var view: ListSpotCell? = controller.ui({ $0.kind == "image" })
    XCTAssertNil(view)

    controller.preloadView()
    controller.viewDidAppear()
    controller.spots.forEach { $0.render().layoutSubviews() }

    view = controller.ui({ $0.kind == "image" })
    XCTAssertNotNil(view)

    /// Test to see if loading the view has any affect on the diff
    oldItems = controller.spots.first!.items
    diff = Item.evaluate(newItems, oldModels: oldItems)
    XCTAssertEqual(diff![0], .text)
    XCTAssertEqual(diff![1], .none)
    XCTAssertEqual(diff![2], .text)
    XCTAssertEqual(diff![3], .text)
    XCTAssertEqual(diff![4], .subtitle)
    XCTAssertEqual(diff![5], .text)

    XCTAssertEqual(controller.spots.first!.component.items[0].title, initialComponents.first!.items[0].title)
    XCTAssertEqual(controller.spots.first!.component.items[0].subtitle, initialComponents.first!.items[0].subtitle)
    XCTAssertEqual(controller.spots.first!.component.items[0].action, initialComponents.first!.items[0].action)
    XCTAssertEqual(controller.spots.first!.component.items[0].kind, initialComponents.first!.items[0].kind)
    XCTAssertNotEqual(controller.spots.first!.component.items[0].size, initialComponents.first!.items[0].size)
    XCTAssertEqual(controller.spots.first!.component.items[0].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
    XCTAssertEqual(controller.spots.first!.component.items[0].size, view!.frame.size)

    XCTAssertEqual(controller.spots.first!.component.items[1].title, initialComponents.first!.items[1].title)
    XCTAssertEqual(controller.spots.first!.component.items[1].subtitle, initialComponents.first!.items[1].subtitle)
    XCTAssertEqual(controller.spots.first!.component.items[1].action, initialComponents.first!.items[1].action)
    XCTAssertEqual(controller.spots.first!.component.items[1].kind, initialComponents.first!.items[1].kind)
    XCTAssertNotEqual(controller.spots.first!.component.items[1].size, initialComponents.first!.items[1].size)
    XCTAssertEqual(controller.spots.first!.component.items[1].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
    XCTAssertEqual(controller.spots.first!.component.items[1].size, view!.frame.size)

    XCTAssertEqual(controller.spots.first!.component.items[2].title, initialComponents.first!.items[2].title)
    XCTAssertEqual(controller.spots.first!.component.items[2].subtitle, initialComponents.first!.items[2].subtitle)
    XCTAssertEqual(controller.spots.first!.component.items[2].action, initialComponents.first!.items[2].action)
    XCTAssertEqual(controller.spots.first!.component.items[2].kind, initialComponents.first!.items[2].kind)
    XCTAssertNotEqual(controller.spots.first!.component.items[2].size, initialComponents.first!.items[2].size)
    XCTAssertEqual(controller.spots.first!.component.items[2].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
    XCTAssertEqual(controller.spots.first!.component.items[2].size, view!.frame.size)

    XCTAssertEqual(controller.spots.first!.component.items[3].title, initialComponents.first!.items[3].title)
    XCTAssertEqual(controller.spots.first!.component.items[3].subtitle, initialComponents.first!.items[3].subtitle)
    XCTAssertEqual(controller.spots.first!.component.items[3].action, initialComponents.first!.items[3].action)
    XCTAssertEqual(controller.spots.first!.component.items[3].kind, initialComponents.first!.items[3].kind)
    XCTAssertNotEqual(controller.spots.first!.component.items[3].size, initialComponents.first!.items[3].size)
    XCTAssertEqual(controller.spots.first!.component.items[3].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
    XCTAssertEqual(controller.spots.first!.component.items[3].size, view!.frame.size)

    XCTAssertEqual(controller.spots.first!.component.items[4].title, initialComponents.first!.items[4].title)
    XCTAssertEqual(controller.spots.first!.component.items[4].subtitle, initialComponents.first!.items[4].subtitle)
    XCTAssertEqual(controller.spots.first!.component.items[4].action, initialComponents.first!.items[4].action)
    XCTAssertEqual(controller.spots.first!.component.items[4].kind, initialComponents.first!.items[4].kind)
    XCTAssertNotEqual(controller.spots.first!.component.items[4].size, initialComponents.first!.items[4].size)
    XCTAssertEqual(controller.spots.first!.component.items[4].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
    XCTAssertEqual(controller.spots.first!.component.items[4].size, view!.frame.size)

    XCTAssertEqual(controller.spots.first!.component.items[5].title, initialComponents.first!.items[5].title)
    XCTAssertEqual(controller.spots.first!.component.items[5].subtitle, initialComponents.first!.items[5].subtitle)
    XCTAssertEqual(controller.spots.first!.component.items[5].action, initialComponents.first!.items[5].action)
    XCTAssertEqual(controller.spots.first!.component.items[5].kind, initialComponents.first!.items[5].kind)
    XCTAssertNotEqual(controller.spots.first!.component.items[5].size, initialComponents.first!.items[5].size)
    XCTAssertEqual(controller.spots.first!.component.items[5].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
    XCTAssertEqual(controller.spots.first!.component.items[5].size, view!.frame.size)

    let exception = self.expectation(description: "Reload controller with components")
    controller.reloadIfNeeded(newComponents) {

      XCTAssertEqual(controller.spots.first!.component.items[0].title, newComponents.first!.items[0].title)
      XCTAssertEqual(controller.spots.first!.component.items[0].subtitle, newComponents.first!.items[0].subtitle)
      XCTAssertEqual(controller.spots.first!.component.items[0].action, newComponents.first!.items[0].action)
      XCTAssertEqual(controller.spots.first!.component.items[0].kind, newComponents.first!.items[0].kind)
      XCTAssertNotEqual(controller.spots.first!.component.items[0].size, newComponents.first!.items[0].size)
      XCTAssertEqual(controller.spots.first!.component.items[0].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(controller.spots.first!.component.items[0].size, view!.frame.size)

      XCTAssertEqual(controller.spots.first!.component.items[1].title, newComponents.first!.items[1].title)
      XCTAssertEqual(controller.spots.first!.component.items[1].subtitle, newComponents.first!.items[1].subtitle)
      XCTAssertEqual(controller.spots.first!.component.items[1].action, newComponents.first!.items[1].action)
      XCTAssertEqual(controller.spots.first!.component.items[1].kind, newComponents.first!.items[1].kind)
      XCTAssertNotEqual(controller.spots.first!.component.items[1].size, newComponents.first!.items[1].size)
      XCTAssertEqual(controller.spots.first!.component.items[1].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(controller.spots.first!.component.items[1].size, view!.frame.size)

      XCTAssertEqual(controller.spots.first!.component.items[2].title, newComponents.first!.items[2].title)
      XCTAssertEqual(controller.spots.first!.component.items[2].subtitle, newComponents.first!.items[2].subtitle)
      XCTAssertEqual(controller.spots.first!.component.items[2].action, newComponents.first!.items[2].action)
      XCTAssertEqual(controller.spots.first!.component.items[2].kind, newComponents.first!.items[2].kind)
      XCTAssertNotEqual(controller.spots.first!.component.items[2].size, newComponents.first!.items[2].size)
      XCTAssertEqual(controller.spots.first!.component.items[2].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(controller.spots.first!.component.items[2].size, view!.frame.size)

      XCTAssertEqual(controller.spots.first!.component.items[3].title, newComponents.first!.items[3].title)
      XCTAssertEqual(controller.spots.first!.component.items[3].subtitle, newComponents.first!.items[3].subtitle)
      XCTAssertEqual(controller.spots.first!.component.items[3].action, newComponents.first!.items[3].action)
      XCTAssertEqual(controller.spots.first!.component.items[3].kind, newComponents.first!.items[3].kind)
      XCTAssertNotEqual(controller.spots.first!.component.items[3].size, newComponents.first!.items[3].size)
      XCTAssertEqual(controller.spots.first!.component.items[3].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(controller.spots.first!.component.items[3].size, view!.frame.size)

      XCTAssertEqual(controller.spots.first!.component.items[4].title, newComponents.first!.items[4].title)
      XCTAssertEqual(controller.spots.first!.component.items[4].subtitle, newComponents.first!.items[4].subtitle)
      XCTAssertEqual(controller.spots.first!.component.items[4].action, newComponents.first!.items[4].action)
      XCTAssertEqual(controller.spots.first!.component.items[4].kind, newComponents.first!.items[4].kind)
      XCTAssertNotEqual(controller.spots.first!.component.items[4].size, newComponents.first!.items[4].size)
      XCTAssertEqual(controller.spots.first!.component.items[4].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(controller.spots.first!.component.items[4].size, view!.frame.size)

      XCTAssertEqual(controller.spots.first!.component.items[5].title, newComponents.first!.items[5].title)
      XCTAssertEqual(controller.spots.first!.component.items[5].subtitle, newComponents.first!.items[5].subtitle)
      XCTAssertEqual(controller.spots.first!.component.items[5].action, newComponents.first!.items[5].action)
      XCTAssertEqual(controller.spots.first!.component.items[5].kind, newComponents.first!.items[5].kind)
      XCTAssertNotEqual(controller.spots.first!.component.items[5].size, newComponents.first!.items[5].size)
      XCTAssertEqual(controller.spots.first!.component.items[5].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(controller.spots.first!.component.items[5].size, view!.frame.size)

      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }
}
