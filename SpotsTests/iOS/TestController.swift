@testable import Spots
import Foundation
import XCTest
import Brick

class ControllerTests : XCTestCase {

  var controller: Controller!

  override func setUp() {
    controller = Controller(spots: [])
  }

  override func tearDown() {
    controller = nil
  }

  func testSpotAtIndex() {
    let component = Component(title: "Component")
    let listSpot = ListSpot(component: component)
    controller = Controller(spot: listSpot)
    controller.preloadView()

    XCTAssertEqual(self.controller.spot as? ListSpot, listSpot)
  }

  func testUpdateSpotAtIndex() {
    let component = Component(title: "Component")
    let listSpot = ListSpot(component: component)
    controller = Controller(spot: listSpot)
    controller.preloadView()
    let items = [Item(title: "item1")]

    controller.update { spot in
      spot.component.items = items
    }

    XCTAssert(self.controller.spot!.component.items == items)
  }

  func testAppendItemInListSpot() {
    let component = Component(title: "Component", kind: "list")
    let listSpot = ListSpot(component: component)
    controller = Controller(spot: listSpot)
    controller.preloadView()

    XCTAssert(self.controller.spot!.component.items.count == 0)

    let item = Item(title: "title1", kind: "list")
    controller.append(item, spotIndex: 0)

    XCTAssert(self.controller.spot!.component.items.count == 1)

    if let testItem = self.controller.spot!.component.items.first {
      XCTAssert(testItem == item)
    }

    // Test appending item without kind
    let exception = self.expectation(description: "Test append item")
    controller.append(Item(title: "title2"), spotIndex: 0) {
      XCTAssert(self.controller.spot!.component.items.count == 2)
      XCTAssertEqual(self.controller.spot!.component.items[1].title, "title2")
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testAppendItemsInListSpot() {
    let component = Component(title: "Component", kind: "list")
    let listSpot = ListSpot(component: component)
    controller = Controller(spot: listSpot)
    controller.preloadView()

    let items = [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list")
    ]
    controller.append(items, spotIndex: 0)

    XCTAssert(self.controller.spot!.component.items.count > 0)
    XCTAssert(self.controller.spot!.component.items == items)

    // Test appending items without kind
    let exception = self.expectation(description: "Test append items")
    controller.append([
      Item(title: "title3"),
      Item(title: "title4")
    ], spotIndex: 0) {
      XCTAssertEqual(self.controller.spot!.component.items.count, 4)
      XCTAssertEqual(self.controller.spot!.component.items[2].title, "title3")
      XCTAssertEqual(self.controller.spot!.component.items[3].title, "title4")
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testPrependItemsInListSpot() {
    let component = Component(title: "Component", kind: "list")
    let listSpot = ListSpot(component: component)
    controller = Controller(spot: listSpot)
    controller.preloadView()

    let items = [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list")
    ]
    controller.prepend(items, spotIndex: 0)

    XCTAssertEqual(self.controller.spot!.component.items.count, 2)
    XCTAssert(self.controller.spot!.component.items == items)

    let exception = self.expectation(description: "Test prepend items")
    controller.prepend([
      Item(title: "title3"),
      Item(title: "title4")
    ], spotIndex: 0) {
      XCTAssertEqual(self.controller.spot!.component.items[0].title, "title3")
      XCTAssertEqual(self.controller.spot!.component.items[1].title, "title4")
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

    controller = Controller(spot: initialListSpot)
    controller.preloadView()

    let firstItem = self.controller.spot!.component.items.first

    XCTAssertEqual(firstItem?.title, "title1")
    XCTAssertEqual(firstItem?.index, 0)

    let exception = self.expectation(description: "Test delete item")
    let listSpot = (self.controller.spot as! ListSpot)
    listSpot.delete(component.items.first!) {
      let lastItem = self.controller.spot!.component.items.first

      XCTAssertNotEqual(lastItem?.title, "title1")
      XCTAssertEqual(lastItem?.index, 0)
      XCTAssertEqual(lastItem?.title, "title2")
      XCTAssertEqual(self.controller.spot!.component.items.count, 1)
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testAppendItemInGridSpot() {
    let component = Component(title: "Component", kind: "grid")
    let listSpot = ListSpot(component: component)
    controller = Controller(spot: listSpot)
    controller.preloadView()

    XCTAssert(self.controller.spot!.component.items.count == 0)

    let item = Item(title: "title1", kind: "grid")
    controller.append(item, spotIndex: 0)

    XCTAssert(self.controller.spot!.component.items.count == 1)

    if let testItem = self.controller.spot!.component.items.first {
      XCTAssert(testItem == item)
    }

    // Test appending item without kind
    let exception = self.expectation(description: "Test append item")
    controller.append(Item(title: "title2"), spotIndex: 0) {
      XCTAssert(self.controller.spot!.component.items.count == 2)
      XCTAssertEqual(self.controller.spot!.component.items[1].title, "title2")
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testAppendItemsInGridSpot() {
    let component = Component(title: "Component", kind: "grid")
    let listSpot = ListSpot(component: component)
    controller = Controller(spot: listSpot)
    controller.preloadView()

    let items = [
      Item(title: "title1", kind: "grid"),
      Item(title: "title2", kind: "grid")
    ]
    controller.append(items, spotIndex: 0)

    XCTAssert(self.controller.spot!.component.items.count > 0)
    XCTAssert(self.controller.spot!.component.items == items)

    // Test appending items without kind
    let exception = self.expectation(description: "Test append items")
    controller.append([
      Item(title: "title3"),
      Item(title: "title4")
    ], spotIndex: 0) {
      XCTAssertEqual(self.controller.spot!.component.items.count, 4)
      XCTAssertEqual(self.controller.spot!.component.items[2].title, "title3")
      XCTAssertEqual(self.controller.spot!.component.items[3].title, "title4")
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testPrependItemsInGridSpot() {
    let component = Component(title: "Component", kind: "grid")
    let listSpot = ListSpot(component: component)
    controller = Controller(spot: listSpot)
    controller.preloadView()

    let items = [
      Item(title: "title1", kind: "grid"),
      Item(title: "title2", kind: "grid")
    ]
    controller.prepend(items, spotIndex: 0)

    XCTAssertEqual(self.controller.spot!.component.items.count, 2)
    XCTAssert(self.controller.spot!.component.items == items)

    let exception = self.expectation(description: "Test prepend items")
    controller.prepend([
      Item(title: "title3"),
      Item(title: "title4")
    ], spotIndex: 0) {
      XCTAssertEqual(self.controller.spot!.component.items[0].title, "title3")
      XCTAssertEqual(self.controller.spot!.component.items[1].title, "title4")
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

    controller = Controller(spot: initialListSpot)
    controller.preloadView()

    let firstItem = self.controller.spot!.component.items.first

    XCTAssertEqual(firstItem?.title, "title1")
    XCTAssertEqual(firstItem?.index, 0)

    let exception = self.expectation(description: "Test delete item")
    let listSpot = (self.controller.spot as! ListSpot)
    listSpot.delete(component.items.first!) {
      let lastItem = self.controller.spot!.component.items.first

      XCTAssertNotEqual(lastItem?.title, "title1")
      XCTAssertEqual(lastItem?.index, 0)
      XCTAssertEqual(lastItem?.title, "title2")
      XCTAssertEqual(self.controller.spot!.component.items.count, 1)
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testAppendItemInCarouselSpot() {
    let component = Component(title: "Component", kind: "carousel")
    let listSpot = ListSpot(component: component)
    controller = Controller(spot: listSpot)
    controller.preloadView()

    XCTAssert(self.controller.spot!.component.items.count == 0)

    let item = Item(title: "title1", kind: "carousel")
    controller.append(item, spotIndex: 0)

    XCTAssert(self.controller.spot!.component.items.count == 1)

    if let testItem = self.controller.spot!.component.items.first {
      XCTAssert(testItem == item)
    }

    // Test appending item without kind
    let exception = self.expectation(description: "Test append item")
    controller.append(Item(title: "title2"), spotIndex: 0) {
      XCTAssert(self.controller.spot!.component.items.count == 2)
      XCTAssertEqual(self.controller.spot!.component.items[1].title, "title2")
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testAppendItemsInCarouselSpot() {
    let component = Component(title: "Component", kind: "carousel")
    let listSpot = ListSpot(component: component)
    controller = Controller(spot: listSpot)
    controller.preloadView()

    let items = [
      Item(title: "title1", kind: "carousel"),
      Item(title: "title2", kind: "carousel")
    ]
    controller.append(items, spotIndex: 0)

    XCTAssert(self.controller.spot!.component.items.count > 0)
    XCTAssert(self.controller.spot!.component.items == items)

    // Test appending items without kind
    let exception = self.expectation(description: "Test append items")
    controller.append([
      Item(title: "title3"),
      Item(title: "title4")
    ], spotIndex: 0) {
      XCTAssertEqual(self.controller.spot!.component.items.count, 4)
      XCTAssertEqual(self.controller.spot!.component.items[2].title, "title3")
      XCTAssertEqual(self.controller.spot!.component.items[3].title, "title4")
      exception.fulfill()
    }
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testPrependItemsInCarouselSpot() {
    let component = Component(title: "Component", kind: "carousel")
    let listSpot = ListSpot(component: component)
    controller = Controller(spot: listSpot)
    controller.preloadView()

    let items = [
      Item(title: "title1", kind: "carousel"),
      Item(title: "title2", kind: "carousel")
    ]
    controller.prepend(items, spotIndex: 0)

    XCTAssertEqual(self.controller.spot!.component.items.count, 2)
    XCTAssert(self.controller.spot!.component.items == items)

    let exception = self.expectation(description: "Test prepend items")
    controller.prepend([
      Item(title: "title3"),
      Item(title: "title4")
    ], spotIndex: 0) {
      XCTAssertEqual(self.controller.spot!.component.items[0].title, "title3")
      XCTAssertEqual(self.controller.spot!.component.items[1].title, "title4")
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

    controller = Controller(spot: initialListSpot)
    controller.preloadView()

    let firstItem = self.controller.spot!.component.items.first

    XCTAssertEqual(firstItem?.title, "title1")
    XCTAssertEqual(firstItem?.index, 0)

    let exception = self.expectation(description: "Test delete item")
    let listSpot = (self.controller.spot as! ListSpot)
    listSpot.delete(component.items.first!) {
      let lastItem = self.controller.spot!.component.items.first

      XCTAssertNotEqual(lastItem?.title, "title1")
      XCTAssertEqual(lastItem?.index, 0)
      XCTAssertEqual(lastItem?.title, "title2")
      XCTAssertEqual(self.controller.spot!.component.items.count, 1)
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
    controller = Controller(spots: [listSpot, listSpot2, gridSpot])

    XCTAssertNotNil(self.controller.resolve(spot: { $1.component.title == "ListSpot" }))
    XCTAssertNotNil(self.controller.resolve(spot: { $1.component.title == "GridSpot" }))
    XCTAssertNotNil(self.controller.resolve(spot: { $1 is Listable }))
    XCTAssertNotNil(self.controller.resolve(spot: { $1 is Gridable }))
    XCTAssertNotNil(self.controller.resolve(spot: { $1.items.filter{ $0.title == "Item" }.first != nil }))
    XCTAssertEqual(self.controller.resolve(spot: { $0.0 == 0 })?.component.title, "ListSpot")
    XCTAssertEqual(self.controller.resolve(spot: { $0.0 == 1 })?.component.title, "ListSpot2")
    XCTAssertEqual(self.controller.resolve(spot: { $0.0 == 2 })?.component.title, "GridSpot")

    XCTAssert(self.controller.filter(spots: { $0 is Listable }).count == 2)
  }

  func testJSONInitialiser() {
    let spot = ListSpot(component: Component())
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

    controller = Controller(initialJSON)
    XCTAssertTrue(self.controller.spots[0] is ListSpot)
    XCTAssertEqual(self.controller.spots[0].items.first?.title, "First list item")
    XCTAssertEqual(self.controller.spots[1].items.first?.title, "First list item")
    XCTAssertTrue(self.controller.spots[1] is ListSpot)
    XCTAssertTrue(self.controller.spots.count == 2)
    XCTAssertTrue(self.controller.compositeSpots.count == 0)

    let exception = self.expectation(description: "Reload multiple times with JSON (if needed)")

    controller.reloadIfNeeded(newJSON) {
      XCTAssertEqual(self.controller.spots.count, 2)
      XCTAssertTrue(self.controller.spots[0] is ListSpot)
      XCTAssertTrue(self.controller.spots[1] is GridSpot)
      XCTAssertEqual(self.controller.spots[0].items.first?.title, "First list item 2")
      XCTAssertEqual(self.controller.spots[1].items.first?.title, "First list item")

      XCTAssertEqual(self.controller.spots[0].items[1].kind, "composite")
      XCTAssertEqual(self.controller.compositeSpots.count, 1)

      self.controller.reloadIfNeeded(initialJSON) {
        XCTAssertTrue(self.controller.spots[0] is ListSpot)
        XCTAssertEqual(self.controller.spots[0].items.first?.title, "First list item")
        XCTAssertEqual(self.controller.spots[1].items.first?.title, "First list item")
        XCTAssertTrue(self.controller.spots[1] is ListSpot)
        XCTAssertTrue(self.controller.spots.count == 2)
        XCTAssertTrue(self.controller.compositeSpots.count == 0)
        exception.fulfill()
      }
    }
    waitForExpectations(timeout: 3.5, handler: nil)
  }

  func testControllerItemChanges() {
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
    controller = Controller(spots: spots)

    let oldComponents: [Component] = self.controller.spots.map { $0.component }

    let changes = self.controller.generateChanges(from: newComponents, and: oldComponents)
    XCTAssertEqual(changes.count, 1)
    XCTAssertEqual(changes.first, .items)

    /// Test what changed on the items
    let newItems = newComponents.first!.items
    let oldItems = self.controller.spots.first!.items
    var diff = Item.evaluate(newItems, oldModels: oldItems)
    XCTAssertEqual(diff![0], .size)
    XCTAssertEqual(diff![1], .size)
    XCTAssertEqual(diff![2], .size)
    XCTAssertEqual(diff![3], .size)
    XCTAssertEqual(diff![4], .size)
    XCTAssertEqual(diff![5], .size)
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

    /// Validate setting up a controller
    controller = Controller(spots: spots)
    XCTAssertEqual(self.controller.spots.count, 1)

    /// Test first item in the first component of the first spot inside of the controller
    XCTAssertEqual(self.controller.spots.first!.component.kind, spots.first!.component.kind)
    XCTAssertEqual(self.controller.spots.first!.component.items[0].title, spots.first!.component.items[0].title)
    XCTAssertEqual(self.controller.spots.first!.component.items[0].subtitle, spots.first!.component.items[0].subtitle)
    XCTAssertEqual(self.controller.spots.first!.component.items[0].kind, spots.first!.component.items[0].kind)
    XCTAssertEqual(self.controller.spots.first!.component.items[0].size, spots.first!.component.items[0].size)

    XCTAssertTrue(initialComponents !== newComponents)
    XCTAssertEqual(initialComponents.count, newComponents.count)
    
    var view: ListSpotCell? = self.controller.ui({ $0.kind == "image" })
    XCTAssertNil(view)

    controller.preloadView()
    controller.viewDidAppear()
    controller.spots.forEach { $0.render().layoutSubviews() }

    view = self.controller.ui({ $0.kind == "image" })
    XCTAssertNotNil(view)

    XCTAssertEqual(self.controller.spots.first!.component.items[0].title, initialComponents.first!.items[0].title)
    XCTAssertEqual(self.controller.spots.first!.component.items[0].subtitle, initialComponents.first!.items[0].subtitle)
    XCTAssertEqual(self.controller.spots.first!.component.items[0].action, initialComponents.first!.items[0].action)
    XCTAssertEqual(self.controller.spots.first!.component.items[0].kind, initialComponents.first!.items[0].kind)
    XCTAssertNotEqual(self.controller.spots.first!.component.items[0].size, initialComponents.first!.items[0].size)
    XCTAssertEqual(self.controller.spots.first!.component.items[0].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
    XCTAssertEqual(self.controller.spots.first!.component.items[0].size, view!.frame.size)

    XCTAssertEqual(self.controller.spots.first!.component.items[1].title, initialComponents.first!.items[1].title)
    XCTAssertEqual(self.controller.spots.first!.component.items[1].subtitle, initialComponents.first!.items[1].subtitle)
    XCTAssertEqual(self.controller.spots.first!.component.items[1].action, initialComponents.first!.items[1].action)
    XCTAssertEqual(self.controller.spots.first!.component.items[1].kind, initialComponents.first!.items[1].kind)
    XCTAssertNotEqual(self.controller.spots.first!.component.items[1].size, initialComponents.first!.items[1].size)
    XCTAssertEqual(self.controller.spots.first!.component.items[1].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
    XCTAssertEqual(self.controller.spots.first!.component.items[1].size, view!.frame.size)

    XCTAssertEqual(self.controller.spots.first!.component.items[2].title, initialComponents.first!.items[2].title)
    XCTAssertEqual(self.controller.spots.first!.component.items[2].subtitle, initialComponents.first!.items[2].subtitle)
    XCTAssertEqual(self.controller.spots.first!.component.items[2].action, initialComponents.first!.items[2].action)
    XCTAssertEqual(self.controller.spots.first!.component.items[2].kind, initialComponents.first!.items[2].kind)
    XCTAssertNotEqual(self.controller.spots.first!.component.items[2].size, initialComponents.first!.items[2].size)
    XCTAssertEqual(self.controller.spots.first!.component.items[2].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
    XCTAssertEqual(self.controller.spots.first!.component.items[2].size, view!.frame.size)

    XCTAssertEqual(self.controller.spots.first!.component.items[3].title, initialComponents.first!.items[3].title)
    XCTAssertEqual(self.controller.spots.first!.component.items[3].subtitle, initialComponents.first!.items[3].subtitle)
    XCTAssertEqual(self.controller.spots.first!.component.items[3].action, initialComponents.first!.items[3].action)
    XCTAssertEqual(self.controller.spots.first!.component.items[3].kind, initialComponents.first!.items[3].kind)
    XCTAssertNotEqual(self.controller.spots.first!.component.items[3].size, initialComponents.first!.items[3].size)
    XCTAssertEqual(self.controller.spots.first!.component.items[3].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
    XCTAssertEqual(self.controller.spots.first!.component.items[3].size, view!.frame.size)

    XCTAssertEqual(self.controller.spots.first!.component.items[4].title, initialComponents.first!.items[4].title)
    XCTAssertEqual(self.controller.spots.first!.component.items[4].subtitle, initialComponents.first!.items[4].subtitle)
    XCTAssertEqual(self.controller.spots.first!.component.items[4].action, initialComponents.first!.items[4].action)
    XCTAssertEqual(self.controller.spots.first!.component.items[4].kind, initialComponents.first!.items[4].kind)
    XCTAssertNotEqual(self.controller.spots.first!.component.items[4].size, initialComponents.first!.items[4].size)
    XCTAssertEqual(self.controller.spots.first!.component.items[4].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
    XCTAssertEqual(self.controller.spots.first!.component.items[4].size, view!.frame.size)

    XCTAssertEqual(self.controller.spots.first!.component.items[5].title, initialComponents.first!.items[5].title)
    XCTAssertEqual(self.controller.spots.first!.component.items[5].subtitle, initialComponents.first!.items[5].subtitle)
    XCTAssertEqual(self.controller.spots.first!.component.items[5].action, initialComponents.first!.items[5].action)
    XCTAssertEqual(self.controller.spots.first!.component.items[5].kind, initialComponents.first!.items[5].kind)
    XCTAssertNotEqual(self.controller.spots.first!.component.items[5].size, initialComponents.first!.items[5].size)
    XCTAssertEqual(self.controller.spots.first!.component.items[5].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
    XCTAssertEqual(self.controller.spots.first!.component.items[5].size, view!.frame.size)

    let exception = self.expectation(description: "Reload controller with components")
    controller.reloadIfNeeded(newComponents) {

      XCTAssertEqual(self.controller.spots.first!.component.items[0].title, newComponents.first!.items[0].title)
      XCTAssertEqual(self.controller.spots.first!.component.items[0].subtitle, newComponents.first!.items[0].subtitle)
      XCTAssertEqual(self.controller.spots.first!.component.items[0].action, newComponents.first!.items[0].action)
      XCTAssertEqual(self.controller.spots.first!.component.items[0].kind, newComponents.first!.items[0].kind)
      XCTAssertNotEqual(self.controller.spots.first!.component.items[0].size, newComponents.first!.items[0].size)
      XCTAssertEqual(self.controller.spots.first!.component.items[0].size, CGSize(width: self.controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(self.controller.spots.first!.component.items[0].size, view!.frame.size)

      XCTAssertEqual(self.controller.spots.first!.component.items[1].title, newComponents.first!.items[1].title)
      XCTAssertEqual(self.controller.spots.first!.component.items[1].subtitle, newComponents.first!.items[1].subtitle)
      XCTAssertEqual(self.controller.spots.first!.component.items[1].action, newComponents.first!.items[1].action)
      XCTAssertEqual(self.controller.spots.first!.component.items[1].kind, newComponents.first!.items[1].kind)
      XCTAssertNotEqual(self.controller.spots.first!.component.items[1].size, newComponents.first!.items[1].size)
      XCTAssertEqual(self.controller.spots.first!.component.items[1].size, CGSize(width: self.controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(self.controller.spots.first!.component.items[1].size, view!.frame.size)

      XCTAssertEqual(self.controller.spots.first!.component.items[2].title, newComponents.first!.items[2].title)
      XCTAssertEqual(self.controller.spots.first!.component.items[2].subtitle, newComponents.first!.items[2].subtitle)
      XCTAssertEqual(self.controller.spots.first!.component.items[2].action, newComponents.first!.items[2].action)
      XCTAssertEqual(self.controller.spots.first!.component.items[2].kind, newComponents.first!.items[2].kind)
      XCTAssertNotEqual(self.controller.spots.first!.component.items[2].size, newComponents.first!.items[2].size)
      XCTAssertEqual(self.controller.spots.first!.component.items[2].size, CGSize(width: self.controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(self.controller.spots.first!.component.items[2].size, view!.frame.size)

      XCTAssertEqual(self.controller.spots.first!.component.items[3].title, newComponents.first!.items[3].title)
      XCTAssertEqual(self.controller.spots.first!.component.items[3].subtitle, newComponents.first!.items[3].subtitle)
      XCTAssertEqual(self.controller.spots.first!.component.items[3].action, newComponents.first!.items[3].action)
      XCTAssertEqual(self.controller.spots.first!.component.items[3].kind, newComponents.first!.items[3].kind)
      XCTAssertNotEqual(self.controller.spots.first!.component.items[3].size, newComponents.first!.items[3].size)
      XCTAssertEqual(self.controller.spots.first!.component.items[3].size, CGSize(width: self.controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(self.controller.spots.first!.component.items[3].size, view!.frame.size)

      XCTAssertEqual(self.controller.spots.first!.component.items[4].title, newComponents.first!.items[4].title)
      XCTAssertEqual(self.controller.spots.first!.component.items[4].subtitle, newComponents.first!.items[4].subtitle)
      XCTAssertEqual(self.controller.spots.first!.component.items[4].action, newComponents.first!.items[4].action)
      XCTAssertEqual(self.controller.spots.first!.component.items[4].kind, newComponents.first!.items[4].kind)
      XCTAssertNotEqual(self.controller.spots.first!.component.items[4].size, newComponents.first!.items[4].size)
      XCTAssertEqual(self.controller.spots.first!.component.items[4].size, CGSize(width: self.controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(self.controller.spots.first!.component.items[4].size, view!.frame.size)

      XCTAssertEqual(self.controller.spots.first!.component.items[5].title, newComponents.first!.items[5].title)
      XCTAssertEqual(self.controller.spots.first!.component.items[5].subtitle, newComponents.first!.items[5].subtitle)
      XCTAssertEqual(self.controller.spots.first!.component.items[5].action, newComponents.first!.items[5].action)
      XCTAssertEqual(self.controller.spots.first!.component.items[5].kind, newComponents.first!.items[5].kind)
      XCTAssertNotEqual(self.controller.spots.first!.component.items[5].size, newComponents.first!.items[5].size)
      XCTAssertEqual(self.controller.spots.first!.component.items[5].size, CGSize(width: self.controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(self.controller.spots.first!.component.items[5].size, view!.frame.size)

      exception.fulfill()
    }
    waitForExpectations(timeout: 1.0, handler: nil)
  }
}
