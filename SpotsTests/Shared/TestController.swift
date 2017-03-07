@testable import Spots
import Foundation
import XCTest

class ControllerTests: XCTestCase {

  func testSpotAtIndex() {
    let model = ComponentModel(title: "ComponentModel", span: 1.0)
    let listSpot = ListComponent(model: model)
    let controller = Controller(spot: listSpot)
    controller.preloadView()

    XCTAssertEqual(controller.spot as? ListComponent, listSpot)
  }

  func testUpdateSpotAtIndex() {
    let model = ComponentModel(title: "ComponentModel", span: 1.0)
    let listSpot = ListComponent(model: model)
    let controller = Controller(spot: listSpot)
    controller.preloadView()
    let items = [Item(title: "item1")]

    controller.update { spot in
      spot.model.items = items
    }

    XCTAssert(controller.spot!.model.items == items)
  }

  func testAppendItemInListComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "list", span: 1.0)
    let listSpot = ListComponent(model: model)
    let controller = Controller(spot: listSpot)
    controller.preloadView()

    XCTAssertEqual(controller.spot!.model.items.count, 0)

    let item = Item(title: "title1", kind: "list")
    let expectation = self.expectation(description: "Test append item")
    controller.append(item, spotIndex: 0) {
      XCTAssertEqual(controller.spot!.model.items.count, 1)
      XCTAssert(controller.spot!.model.items.first! == item)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendOneMoreItemInListComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "list", span: 1.0, items: [Item(title: "title1")])
    let listSpot = ListComponent(model: model)
    let controller = Controller(spot: listSpot)
    controller.preloadView()

    XCTAssertEqual(controller.spot!.model.items.count, 1)

    let item = Item(title: "title2", kind: "list")
    let expectation = self.expectation(description: "Test append item")
    controller.append(item, spotIndex: 0) {
      XCTAssertEqual(controller.spot!.model.items.count, 2)
      XCTAssert(controller.spot!.model.items.last! == item)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendItemsInListComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "list", span: 1.0)
    let listSpot = ListComponent(model: model)
    let controller = Controller(spot: listSpot)
    controller.preloadView()

    let items = [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list")
    ]
    let expectation = self.expectation(description: "Test append items")
    controller.append(items, spotIndex: 0) {
      XCTAssert(controller.spot!.model.items.count > 0)
      XCTAssert(controller.spot!.model.items == items)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testPrependItemsInListComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "list", span: 1.0)
    let listSpot = ListComponent(model: model)
    let controller = Controller(spot: listSpot)
    controller.preloadView()

    let items = [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list")
    ]
    let expectation = self.expectation(description: "Test prepend items")
    controller.prepend(items, spotIndex: 0) {
      XCTAssertEqual(controller.spot!.model.items.count, 2)
      XCTAssert(controller.spot!.model.items == items)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testPrependMoreItemsInListComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "list", span: 1.0, items: [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list")
      ]
    )
    let listSpot = ListComponent(model: model)
    let controller = Controller(spot: listSpot)

    controller.preloadView()

    let items = [
      Item(title: "title3", kind: "list"),
      Item(title: "title4", kind: "list")
    ]
    let expectation = self.expectation(description: "Test prepend items")
    controller.prepend(items, spotIndex: 0) {
      XCTAssertEqual(controller.spot!.model.items.count, 4)
      XCTAssertEqual(controller.spot!.model.items[0].title, "title3")
      XCTAssertEqual(controller.spot!.model.items[1].title, "title4")
      XCTAssertEqual(controller.spot!.model.items[2].title, "title1")
      XCTAssertEqual(controller.spot!.model.items[3].title, "title2")
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testDeleteItemInListComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "list", span: 1.0, items: [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list")
      ])
    let initialListComponent = ListComponent(model: model)
    let controller = Controller(spot: initialListComponent)

    controller.preloadView()

    let firstItem = controller.spot!.model.items.first

    XCTAssertEqual(firstItem?.title, "title1")
    XCTAssertEqual(firstItem?.index, 0)

    let expectation = self.expectation(description: "Test delete item")
    let listSpot = (controller.spot as! ListComponent)
    listSpot.delete(model.items.first!) {
      let lastItem = controller.spot!.model.items.first

      XCTAssertNotEqual(lastItem?.title, "title1")
      XCTAssertEqual(lastItem?.index, 0)
      XCTAssertEqual(lastItem?.title, "title2")
      XCTAssertEqual(controller.spot!.model.items.count, 1)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testDeleteItemsInListComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "list", span: 1.0, items: [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list")
    ])
    let initialListComponent = ListComponent(model: model)
    let controller = Controller(spot: initialListComponent)

    controller.preloadView()

    let items = controller.spots.first!.items
    let expectation = self.expectation(description: "Test delete items")

    controller.spots[0].delete(items, withAnimation: .none) {
      XCTAssertEqual(controller.spot!.model.items.count, 0)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testDeleteItemAtIndexInListComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "list", span: 1.0, items: [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list"),
      Item(title: "title3", kind: "list"),
      Item(title: "title4", kind: "list")
      ])
    let initialListComponent = ListComponent(model: model)
    let controller = Controller(spot: initialListComponent)

    controller.preloadView()

    let expectation = self.expectation(description: "Test delete items")

    controller.spots[0].delete(1, withAnimation: .none) {
      XCTAssertEqual(controller.spot!.model.items.count, 3)
      XCTAssertEqual(controller.spot!.model.items[0].title, "title1")
      XCTAssertEqual(controller.spot!.model.items[1].title, "title3")
      XCTAssertEqual(controller.spot!.model.items[2].title, "title4")
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testDeleteItemsWithIndexesInListComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "list", span: 1.0, items: [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list"),
      Item(title: "title3", kind: "list"),
      Item(title: "title4", kind: "list")
      ])
    let initialListComponent = ListComponent(model: model)
    let controller = Controller(spot: initialListComponent)

    controller.preloadView()

    let expectation = self.expectation(description: "Test delete items")

    controller.spots[0].delete([1, 2], withAnimation: .none) {
      XCTAssertEqual(controller.spot!.model.items.count, 2)
      XCTAssertEqual(controller.spot!.model.items[0].title, "title1")
      XCTAssertEqual(controller.spot!.model.items[1].title, "title4")
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendItemInGridComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "grid", span: 1.0)
    let listSpot = ListComponent(model: model)
    let controller = Controller(spot: listSpot)

    controller.preloadView()

    XCTAssert(controller.spot!.model.items.count == 0)

    let item = Item(title: "title1", kind: "grid")
    let expectation = self.expectation(description: "Test append item")

    controller.append(item, spotIndex: 0) {
      XCTAssert(controller.spot!.model.items.count == 1)
      XCTAssert(controller.spot!.model.items.first! == item)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendItemsInGridComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "grid", span: 1.0)
    let listSpot = ListComponent(model: model)
    let controller = Controller(spot: listSpot)

    controller.preloadView()

    let items = [
      Item(title: "title1", kind: "grid"),
      Item(title: "title2", kind: "grid")
    ]
    let expectation = self.expectation(description: "Test append items")
    controller.append(items, spotIndex: 0) {
      XCTAssert(controller.spot!.model.items.count > 0)
      XCTAssert(controller.spot!.model.items == items)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testPrependItemsInGridComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "grid", span: 1.0)
    let listSpot = ListComponent(model: model)
    let controller = Controller(spot: listSpot)

    controller.preloadView()

    let items = [
      Item(title: "title1", kind: "grid"),
      Item(title: "title2", kind: "grid")
    ]
    let expectation = self.expectation(description: "Test prepend items")
    controller.prepend(items, spotIndex: 0) {
      XCTAssertEqual(controller.spot!.model.items.count, 2)
      XCTAssert(controller.spot!.model.items == items)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testDeleteItemInGridComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "grid", span: 1.0, items: [
      Item(title: "title1", kind: "grid"),
      Item(title: "title2", kind: "grid")
      ])
    let initialListComponent = ListComponent(model: model)
    let controller = Controller(spot: initialListComponent)

    controller.preloadView()

    let firstItem = controller.spot!.model.items.first

    XCTAssertEqual(firstItem?.title, "title1")
    XCTAssertEqual(firstItem?.index, 0)

    let expectation = self.expectation(description: "Test delete item")
    let listSpot = (controller.spot as! ListComponent)
    listSpot.delete(model.items.first!) {
      let lastItem = controller.spot!.model.items.first

      XCTAssertNotEqual(lastItem?.title, "title1")
      XCTAssertEqual(lastItem?.index, 0)
      XCTAssertEqual(lastItem?.title, "title2")
      XCTAssertEqual(controller.spot!.model.items.count, 1)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendItemInCarouselComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "carousel", span: 1.0)
    let listSpot = GridComponent(model: model)
    let controller = Controller(spot: listSpot)

    controller.preloadView()

    XCTAssert(controller.spot!.model.items.count == 0)

    let item = Item(title: "title1", kind: "carousel")
    let expectation = self.expectation(description: "Test append item")

    controller.append(item, spotIndex: 0) {
      XCTAssert(controller.spot!.model.items.count == 1)
      XCTAssert(controller.spot!.model.items.first! == item)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendItemsInCarouselComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "carousel", span: 1.0)
    let listSpot = GridComponent(model: model)
    let controller = Controller(spot: listSpot)

    controller.preloadView()

    let items = [
      Item(title: "title1", kind: "carousel"),
      Item(title: "title2", kind: "carousel")
    ]
    let expectation = self.expectation(description: "Test append items")

    controller.append(items, spotIndex: 0) {
      XCTAssert(controller.spot!.model.items.count > 0)
      XCTAssert(controller.spot!.model.items == items)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testPrependItemsInCarouselComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "carousel", span: 1.0)
    let listSpot = ListComponent(model: model)
    let controller = Controller(spot: listSpot)

    controller.preloadView()

    let items = [
      Item(title: "title1", kind: "carousel"),
      Item(title: "title2", kind: "carousel")
    ]
    let expectation = self.expectation(description: "Test prepend items")
    controller.prepend(items, spotIndex: 0) {
      XCTAssertEqual(controller.spot!.model.items.count, 2)
      XCTAssert(controller.spot!.model.items == items)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testDeleteItemInCarouselComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "carousel", span: 1.0, items: [
      Item(title: "title1", kind: "carousel"),
      Item(title: "title2", kind: "carousel")
      ])
    let initialListComponent = ListComponent(model: model)
    let controller = Controller(spot: initialListComponent)

    controller.preloadView()

    let firstItem = controller.spot!.model.items.first

    XCTAssertEqual(firstItem?.title, "title1")
    XCTAssertEqual(firstItem?.index, 0)

    let expectation = self.expectation(description: "Test delete item")
    let listSpot = (controller.spot as! ListComponent)
    listSpot.delete(model.items.first!) {
      let lastItem = controller.spot!.model.items.first

      XCTAssertNotEqual(lastItem?.title, "title1")
      XCTAssertEqual(lastItem?.index, 0)
      XCTAssertEqual(lastItem?.title, "title2")
      XCTAssertEqual(controller.spot!.model.items.count, 1)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testComputedPropertiesOnCoreComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "list", span: 1.0, items: [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list")
      ])
    let component = ListComponent(model: model)

    XCTAssert(component.items == model.items)

    let newItems = [Item(title: "title3", kind: "list")]
    component.items = newItems
    XCTAssertFalse(component.items == model.items)
    XCTAssert(component.items == newItems)
  }

  func testFindAndFilterSpotWithClosure() {
    let listSpot = ListComponent(model: ComponentModel(title: "ListComponent", span: 1.0))
    let listSpot2 = ListComponent(model: ComponentModel(title: "ListComponent2", span: 1.0))
    let gridSpot = GridComponent(model: ComponentModel(title: "GridComponent", span: 1.0, items: [Item(title: "Item")]))
    let controller = Controller(spots: [listSpot, listSpot2, gridSpot])

    XCTAssertNotNil(controller.resolve(spot: { $1.model.title == "ListComponent" }))
    XCTAssertNotNil(controller.resolve(spot: { $1.model.title == "GridComponent" }))
    XCTAssertNotNil(controller.resolve(spot: { $1 is Listable }))
    XCTAssertNotNil(controller.resolve(spot: { $1 is Gridable }))
    XCTAssertNotNil(controller.resolve(spot: { $1.items.filter { $0.title == "Item" }.first != nil }))
    XCTAssertEqual(controller.resolve(spot: { $0.0 == 0 })?.model.title, "ListComponent")
    XCTAssertEqual(controller.resolve(spot: { $0.0 == 1 })?.model.title, "ListComponent2")
    XCTAssertEqual(controller.resolve(spot: { $0.0 == 2 })?.model.title, "GridComponent")

    XCTAssert(controller.filter(spots: { $0 is Listable }).count == 2)
  }

  func testJSONInitialiser() {
    let component = ListComponent(model: ComponentModel(span: 1.0))
    component.items = [Item(title: "First item")]
    let sourceController = Controller(spot: component)
    let jsonController = Controller([
      "components": [
        ["kind": "list",
         "layout": ListComponent.layout.dictionary,
         "items": [
          ["title": "First item"]
          ]
        ]
      ]
      ])

    XCTAssert(sourceController.spot!.model == jsonController.spot!.model)
  }

  func testJSONReload() {
    let initialJSON = [
      "components": [
        ["kind": "list",
         "items": [
          ["title": "First list item"]
          ]
        ]
      ]
    ]
    let jsonController = Controller(initialJSON)

    XCTAssert(jsonController.spot!.model.kind == "list")
    XCTAssert(jsonController.spot!.model.items.count == 1)
    XCTAssert(jsonController.spot!.model.items.first?.title == "First list item")

    let updateJSON = [
      "components": [
        ["kind": "grid",
         "items": [
          ["title": "First grid item"],
          ["title": "Second grid item"]
          ]
        ]
      ]
    ]

    let expectation = self.expectation(description: "Reload with JSON")
    jsonController.reload(updateJSON) {
      XCTAssert(jsonController.spot!.model.kind == "grid")
      XCTAssert(jsonController.spot!.model.items.count == 2)
      XCTAssert(jsonController.spot!.model.items.first?.title == "First grid item")
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testDictionaryOnController() {
    let initialJSON = [
      "components": [
        ["kind": "list",
         "items": [
          ["title": "First list item"]
          ]
        ]
      ]
    ]
    let firstController = Controller(initialJSON)
    let secondController = Controller(firstController.dictionary)

    XCTAssertTrue(firstController.spots.first!.model == secondController.spots.first!.model)
  }

  func testReloadIfNeededWithJSON() {
    let initialJSON: [String : Any] = [
      "components": [
        ["kind": "list",
         "items": [
          ["title": "First list item"]
          ]
        ],
        ["kind": "list",
         "items": [
          ["title": "First list item"]
          ]
        ]
      ]
    ]

    let newJSON: [String : Any] = [
      "components": [
        ["kind": "list",
         "items": [
          ["title": "First list item 2"],
          [
            "kind": "composite",
            "children": [
              ["kind": "grid",
               "items": [
                ["title": "First list item"]
                ]
              ]
            ]
          ]
          ]
        ],
        ["kind": "grid",
         "items": [
          ["title": "First list item"]
          ]
        ]
      ]
    ]

    let controller = Controller(initialJSON)
    XCTAssertTrue(controller.spots[0] is ListComponent)
    XCTAssertEqual(controller.spots[0].items.first?.title, "First list item")
    XCTAssertEqual(controller.spots[1].items.first?.title, "First list item")
    XCTAssertTrue(controller.spots[1] is ListComponent)
    XCTAssertTrue(controller.spots.count == 2)
    XCTAssertTrue(controller.spots[0].compositeComponents.count == 0)

    let expectation = self.expectation(description: "Reload multiple times with JSON (if needed)")

    controller.reloadIfNeeded(newJSON) {
      XCTAssertEqual(controller.spots.count, 2)
      XCTAssertTrue(controller.spots[0] is ListComponent)
      XCTAssertTrue(controller.spots[1] is GridComponent)
      XCTAssertEqual(controller.spots[0].items.first?.title, "First list item 2")
      XCTAssertEqual(controller.spots[1].items.first?.title, "First list item")

      XCTAssertEqual(controller.spots[0].items[1].kind, "composite")
      XCTAssertEqual(controller.spots[0].compositeComponents.count, 1)

      controller.reloadIfNeeded(initialJSON) {
        XCTAssertTrue(controller.spots[0] is ListComponent)
        XCTAssertEqual(controller.spots[0].items.first?.title, "First list item")
        XCTAssertEqual(controller.spots[1].items.first?.title, "First list item")
        XCTAssertTrue(controller.spots[1] is ListComponent)
        XCTAssertTrue(controller.spots.count == 2)
        XCTAssertTrue(controller.spots[0].compositeComponents.count == 0)
        expectation.fulfill()
      }
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testControllerItemChanges() {
    let initialComponentModels = [
      ComponentModel(
        kind: "list",
        span: 1.0,
        items: [
          Item(title: "Fullname", subtitle: "Job title", kind: "image"),
          Item(title: "Follow", kind: "toggle", meta: ["dynamic-height": true]),
          Item(title: "First name", subtitle: "Input first name", kind: "info"),
          Item(title: "Last name", subtitle: "Input last name", kind: "info"),
          Item(title: "Twitter", subtitle: "@twitter", kind: "info"),
          Item(title: "", subtitle: "Biography", kind: "core", meta: ["dynamic-height": true])
        ]
      )
    ]

    let newComponentModels = [
      ComponentModel(
        kind: "list",
        span: 1.0,
        items: [
          Item(title: "Fullname", subtitle: "Job title", text: "Bot", kind: "image"),
          Item(title: "Follow", kind: "toggle", meta: ["dynamic-height": true]),
          Item(title: "First name", subtitle: "Input first name", text: "John", kind: "info"),
          Item(title: "Last name", subtitle: "Input last name", text: "Hyperseed", kind: "info"),
          Item(title: "Twitter", subtitle: "@johnhyperseed", kind: "info"),
          Item(subtitle: "Biography", text: "John Hyperseed is a bot", kind: "core", meta: ["dynamic-height": true])
        ]
      )
    ]

    let spots = initialComponentModels.map { Factory.resolve(model: $0) }
    let controller = Controller(spots: spots)

    let oldComponentModels: [ComponentModel] = controller.spots.map { $0.model }

    let changes = controller.generateChanges(from: newComponentModels, and: oldComponentModels)
    XCTAssertEqual(changes.count, 1)
    XCTAssertEqual(changes.first, .items)

    /// Test what changed on the items
    let newItems = newComponentModels.first!.items
    let oldItems = controller.spots.first!.items
    var diff = Item.evaluate(newItems, oldModels: oldItems)

    XCTAssertEqual(diff![0], .text)
    XCTAssertEqual(diff![1], .none)
    XCTAssertEqual(diff![2], .text)
    XCTAssertEqual(diff![3], .text)
    XCTAssertEqual(diff![4], .subtitle)
    XCTAssertEqual(diff![5], .text)
  }

  func testReloadWithComponentModels() {
    let initialComponentModels = [
      ComponentModel(
        kind: "list",
        span: 1.0,
        items: [
          Item(title: "Fullname", subtitle: "Job title", kind: "image"),
          Item(title: "Follow", kind: "toggle", meta: ["dynamic-height": true]),
          Item(title: "First name", subtitle: "Input first name", kind: "info"),
          Item(title: "Last name", subtitle: "Input last name", kind: "info"),
          Item(title: "Twitter", subtitle: "@twitter", kind: "info"),
          Item(title: "", subtitle: "Biography", kind: "core", meta: ["dynamic-height": true])
        ]
      )
    ]

    let newComponentModels = [
      ComponentModel(
        kind: "list",
        span: 1.0,
        items: [
          Item(title: "Fullname", subtitle: "Job title", text: "Bot", kind: "image"),
          Item(title: "Follow", kind: "toggle", meta: ["dynamic-height": true]),
          Item(title: "First name", subtitle: "Input first name", text: "John", kind: "info"),
          Item(title: "Last name", subtitle: "Input last name", text: "Hyperseed", kind: "info"),
          Item(title: "Twitter", subtitle: "@johnhyperseed", kind: "info"),
          Item(subtitle: "Biography", text: "John Hyperseed is a bot", kind: "core", meta: ["dynamic-height": true])
        ]
      )
    ]

    let spots = initialComponentModels.map { Factory.resolve(model: $0) }

    /// Validate setting up a controller
    let controller = Controller(spots: spots)
    XCTAssertEqual(controller.spots.count, 1)

    /// Test first item in the first component of the first spot inside of the controller
    XCTAssertEqual(controller.spots.first!.model.kind, spots.first!.model.kind)
    XCTAssertEqual(controller.spots.first!.model.items[0].title, spots.first!.model.items[0].title)
    XCTAssertEqual(controller.spots.first!.model.items[0].subtitle, spots.first!.model.items[0].subtitle)
    XCTAssertEqual(controller.spots.first!.model.items[0].kind, spots.first!.model.items[0].kind)
    XCTAssertEqual(controller.spots.first!.model.items[0].size, spots.first!.model.items[0].size)

    XCTAssertTrue(initialComponentModels !== newComponentModels)
    XCTAssertEqual(initialComponentModels.count, newComponentModels.count)

    #if os(OSX)
      var view: ListComponentItem? = controller.ui({ $0.kind == "image" })
    #else
      var view: ListComponentCell? = controller.ui({ $0.kind == "image" })
      XCTAssertNil(view)
    #endif

    controller.prepareController()

    /// Reset layout margins for tvOS
    #if os(tvOS)
      controller.spot(at: 0, ofType: ListComponent.self)?.tableView.layoutMargins = UIEdgeInsets.zero
    #endif

    #if !os(OSX)
      view = controller.ui({ $0.kind == "image" })
      XCTAssertNotNil(view)
    #endif

    XCTAssertEqual(controller.spots.first!.model.items[0].title, initialComponentModels.first!.items[0].title)
    XCTAssertEqual(controller.spots.first!.model.items[0].subtitle, initialComponentModels.first!.items[0].subtitle)
    XCTAssertEqual(controller.spots.first!.model.items[0].action, initialComponentModels.first!.items[0].action)
    XCTAssertEqual(controller.spots.first!.model.items[0].kind, initialComponentModels.first!.items[0].kind)
    XCTAssertNotEqual(controller.spots.first!.model.items[0].size, initialComponentModels.first!.items[0].size)

    #if !os(OSX)
      XCTAssertEqual(controller.spots.first!.model.items[0].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(controller.spots.first!.model.items[0].size, view!.frame.size)
    #endif

    XCTAssertEqual(controller.spots.first!.model.items[1].title, initialComponentModels.first!.items[1].title)
    XCTAssertEqual(controller.spots.first!.model.items[1].subtitle, initialComponentModels.first!.items[1].subtitle)
    XCTAssertEqual(controller.spots.first!.model.items[1].action, initialComponentModels.first!.items[1].action)
    XCTAssertEqual(controller.spots.first!.model.items[1].kind, initialComponentModels.first!.items[1].kind)
    XCTAssertNotEqual(controller.spots.first!.model.items[1].size, initialComponentModels.first!.items[1].size)
    #if !os(OSX)
      XCTAssertEqual(controller.spots.first!.model.items[1].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(controller.spots.first!.model.items[1].size, view!.frame.size)
    #endif

    XCTAssertEqual(controller.spots.first!.model.items[2].title, initialComponentModels.first!.items[2].title)
    XCTAssertEqual(controller.spots.first!.model.items[2].subtitle, initialComponentModels.first!.items[2].subtitle)
    XCTAssertEqual(controller.spots.first!.model.items[2].action, initialComponentModels.first!.items[2].action)
    XCTAssertEqual(controller.spots.first!.model.items[2].kind, initialComponentModels.first!.items[2].kind)
    XCTAssertNotEqual(controller.spots.first!.model.items[2].size, initialComponentModels.first!.items[2].size)
    #if !os(OSX)
      XCTAssertEqual(controller.spots.first!.model.items[2].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(controller.spots.first!.model.items[2].size, view!.frame.size)
    #endif

    XCTAssertEqual(controller.spots.first!.model.items[3].title, initialComponentModels.first!.items[3].title)
    XCTAssertEqual(controller.spots.first!.model.items[3].subtitle, initialComponentModels.first!.items[3].subtitle)
    XCTAssertEqual(controller.spots.first!.model.items[3].action, initialComponentModels.first!.items[3].action)
    XCTAssertEqual(controller.spots.first!.model.items[3].kind, initialComponentModels.first!.items[3].kind)
    XCTAssertNotEqual(controller.spots.first!.model.items[3].size, initialComponentModels.first!.items[3].size)

    #if !os(OSX)
      XCTAssertEqual(controller.spots.first!.model.items[3].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(controller.spots.first!.model.items[3].size, view!.frame.size)
    #endif

    XCTAssertEqual(controller.spots.first!.model.items[4].title, initialComponentModels.first!.items[4].title)
    XCTAssertEqual(controller.spots.first!.model.items[4].subtitle, initialComponentModels.first!.items[4].subtitle)
    XCTAssertEqual(controller.spots.first!.model.items[4].action, initialComponentModels.first!.items[4].action)
    XCTAssertEqual(controller.spots.first!.model.items[4].kind, initialComponentModels.first!.items[4].kind)
    XCTAssertNotEqual(controller.spots.first!.model.items[4].size, initialComponentModels.first!.items[4].size)

    #if !os(OSX)
      XCTAssertEqual(controller.spots.first!.model.items[4].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(controller.spots.first!.model.items[4].size, view!.frame.size)
    #endif

    XCTAssertEqual(controller.spots.first!.model.items[5].title, initialComponentModels.first!.items[5].title)
    XCTAssertEqual(controller.spots.first!.model.items[5].subtitle, initialComponentModels.first!.items[5].subtitle)
    XCTAssertEqual(controller.spots.first!.model.items[5].action, initialComponentModels.first!.items[5].action)
    XCTAssertEqual(controller.spots.first!.model.items[5].kind, initialComponentModels.first!.items[5].kind)
    XCTAssertNotEqual(controller.spots.first!.model.items[5].size, initialComponentModels.first!.items[5].size)

    #if !os(OSX)
      XCTAssertEqual(controller.spots.first!.model.items[5].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(controller.spots.first!.model.items[5].size, view!.frame.size)
    #endif

    let expectation = self.expectation(description: "Reload controller with components")
    controller.reloadIfNeeded(newComponentModels) {
      XCTAssertEqual(controller.spots.first!.model.items[0].title, newComponentModels.first!.items[0].title)
      XCTAssertEqual(controller.spots.first!.model.items[0].subtitle, newComponentModels.first!.items[0].subtitle)
      XCTAssertEqual(controller.spots.first!.model.items[0].action, newComponentModels.first!.items[0].action)
      XCTAssertEqual(controller.spots.first!.model.items[0].kind, newComponentModels.first!.items[0].kind)
      XCTAssertNotEqual(controller.spots.first!.model.items[0].size, newComponentModels.first!.items[0].size)
      #if !os(OSX)
        XCTAssertEqual(controller.spots.first!.model.items[0].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
        XCTAssertEqual(controller.spots.first!.model.items[0].size, view!.frame.size)
      #endif

      XCTAssertEqual(controller.spots.first!.model.items[1].title, newComponentModels.first!.items[1].title)
      XCTAssertEqual(controller.spots.first!.model.items[1].subtitle, newComponentModels.first!.items[1].subtitle)
      XCTAssertEqual(controller.spots.first!.model.items[1].action, newComponentModels.first!.items[1].action)
      XCTAssertEqual(controller.spots.first!.model.items[1].kind, newComponentModels.first!.items[1].kind)
      XCTAssertNotEqual(controller.spots.first!.model.items[1].size, newComponentModels.first!.items[1].size)
      #if !os(OSX)
        XCTAssertEqual(controller.spots.first!.model.items[1].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
        XCTAssertEqual(controller.spots.first!.model.items[1].size, view!.frame.size)
      #endif

      XCTAssertEqual(controller.spots.first!.model.items[2].title, newComponentModels.first!.items[2].title)
      XCTAssertEqual(controller.spots.first!.model.items[2].subtitle, newComponentModels.first!.items[2].subtitle)
      XCTAssertEqual(controller.spots.first!.model.items[2].action, newComponentModels.first!.items[2].action)
      XCTAssertEqual(controller.spots.first!.model.items[2].kind, newComponentModels.first!.items[2].kind)
      XCTAssertNotEqual(controller.spots.first!.model.items[2].size, newComponentModels.first!.items[2].size)
      #if !os(OSX)
        XCTAssertEqual(controller.spots.first!.model.items[2].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
        XCTAssertEqual(controller.spots.first!.model.items[2].size, view!.frame.size)
      #endif

      XCTAssertEqual(controller.spots.first!.model.items[3].title, newComponentModels.first!.items[3].title)
      XCTAssertEqual(controller.spots.first!.model.items[3].subtitle, newComponentModels.first!.items[3].subtitle)
      XCTAssertEqual(controller.spots.first!.model.items[3].action, newComponentModels.first!.items[3].action)
      XCTAssertEqual(controller.spots.first!.model.items[3].kind, newComponentModels.first!.items[3].kind)
      XCTAssertNotEqual(controller.spots.first!.model.items[3].size, newComponentModels.first!.items[3].size)
      #if !os(OSX)
        XCTAssertEqual(controller.spots.first!.model.items[3].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
        XCTAssertEqual(controller.spots.first!.model.items[3].size, view!.frame.size)
      #endif

      XCTAssertEqual(controller.spots.first!.model.items[4].title, newComponentModels.first!.items[4].title)
      XCTAssertEqual(controller.spots.first!.model.items[4].subtitle, newComponentModels.first!.items[4].subtitle)
      XCTAssertEqual(controller.spots.first!.model.items[4].action, newComponentModels.first!.items[4].action)
      XCTAssertEqual(controller.spots.first!.model.items[4].kind, newComponentModels.first!.items[4].kind)
      XCTAssertNotEqual(controller.spots.first!.model.items[4].size, newComponentModels.first!.items[4].size)
      #if !os(OSX)
        XCTAssertEqual(controller.spots.first!.model.items[4].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
        XCTAssertEqual(controller.spots.first!.model.items[4].size, view!.frame.size)
      #endif

      XCTAssertEqual(controller.spots.first!.model.items[5].title, newComponentModels.first!.items[5].title)
      XCTAssertEqual(controller.spots.first!.model.items[5].subtitle, newComponentModels.first!.items[5].subtitle)
      XCTAssertEqual(controller.spots.first!.model.items[5].action, newComponentModels.first!.items[5].action)
      XCTAssertEqual(controller.spots.first!.model.items[5].kind, newComponentModels.first!.items[5].kind)
      XCTAssertNotEqual(controller.spots.first!.model.items[5].size, newComponentModels.first!.items[5].size)
      #if !os(OSX)
        XCTAssertEqual(controller.spots.first!.model.items[5].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
        XCTAssertEqual(controller.spots.first!.model.items[5].size, view!.frame.size)
      #endif

      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testSpotsDidReloadComponentModels() {
    let initialComponentModels = [
      ComponentModel(
        kind: "list",
        span: 1.0,
        items: [
          Item(title: "Fullname", subtitle: "Job title", kind: "image"),
          Item(title: "Follow", kind: "toggle", meta: ["dynamic-height": true]),
          Item(title: "First name", subtitle: "Input first name", kind: "info"),
          Item(title: "Last name", subtitle: "Input last name", kind: "info"),
          Item(title: "Twitter", subtitle: "@twitter", kind: "info"),
          Item(title: "", subtitle: "Biography", kind: "core", meta: ["dynamic-height": true])
        ]
      )
    ]

    let newComponentModels = [
      ComponentModel(
        kind: "list",
        span: 1.0,
        items: [
          Item(title: "Fullname", subtitle: "Job title", text: "Bot", kind: "image"),
          Item(title: "Follow", kind: "toggle", meta: ["dynamic-height": true]),
          Item(title: "First name", subtitle: "Input first name", text: "John", kind: "info"),
          Item(title: "Last name", subtitle: "Input last name", text: "Hyperseed", kind: "info"),
          Item(title: "Twitter", subtitle: "@johnhyperseed", kind: "info"),
          Item(subtitle: "Biography", text: "John Hyperseed is a bot", kind: "core", meta: ["dynamic-height": true])
        ]
      )
    ]

    let expectation = self.expectation(description: "Wait for spotsDidReloadComponentModels to be called")

    Controller.spotsDidReloadComponentModels = { controller in
      XCTAssert(true)
      expectation.fulfill()
    }

    let spots = initialComponentModels.map { Factory.resolve(model: $0) }
    let controller = Controller(spots: spots)

    controller.prepareController()
    controller.reloadIfNeeded(newComponentModels)

    waitForExpectations(timeout: 10.0, handler: nil)
  }
}
