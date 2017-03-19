@testable import Spots
import Foundation
import XCTest

class ControllerTests: XCTestCase {

  func testSpotAtIndex() {
    let model = ComponentModel(title: "ComponentModel", span: 1.0)
    let listComponent = ListComponent(model: model)
    let controller = Controller(component: listComponent)
    controller.preloadView()

    XCTAssertEqual(controller.components.first, listComponent)
  }

  func testUpdateSpotAtIndex() {
    let model = ComponentModel(title: "ComponentModel", span: 1.0)
    let listComponent = ListComponent(model: model)
    let controller = Controller(component: listComponent)
    controller.preloadView()
    let items = [Item(title: "item1")]

    controller.update { component in
      component.model.items = items
    }

    guard let firstItems = controller.components.first?.model.items else {
      XCTFail("Unable to resolve items of first component.")
      return
    }

    XCTAssert(firstItems == items)
  }

  func testAppendItemInListComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "list", span: 1.0)
    let listComponent = ListComponent(model: model)
    let controller = Controller(component: listComponent)
    controller.preloadView()

    XCTAssertEqual(controller.components.first?.model.items.count, 0)

    let item = Item(title: "title1", kind: "list")
    let expectation = self.expectation(description: "Test append item")

    controller.append(item, componentIndex: 0) {
      XCTAssertEqual(controller.components.first?.model.items.count, 1)

      guard let firstItem = controller.components.first?.model.items.first else {
        XCTFail("Unable to resolve first item of first component.")
        return
      }

      XCTAssert(firstItem == item)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendOneMoreItemInListComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "list", span: 1.0, items: [Item(title: "title1")])
    let listComponent = ListComponent(model: model)
    let controller = Controller(component: listComponent)
    controller.preloadView()

    XCTAssertEqual(controller.components.first!.model.items.count, 1)

    let item = Item(title: "title2", kind: "list")
    let expectation = self.expectation(description: "Test append item")
    controller.append(item, componentIndex: 0) {
      XCTAssertEqual(controller.components.first!.model.items.count, 2)
      XCTAssert(controller.components.first!.model.items.last! == item)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendItemsInListComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "list", span: 1.0)
    let listComponent = ListComponent(model: model)
    let controller = Controller(component: listComponent)
    controller.preloadView()

    let items = [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list")
    ]
    let expectation = self.expectation(description: "Test append items")
    controller.append(items, componentIndex: 0) {
      XCTAssert(controller.components.first!.model.items.count > 0)
      XCTAssert(controller.components.first!.model.items == items)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testPrependItemsInListComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "list", span: 1.0)
    let listComponent = ListComponent(model: model)
    let controller = Controller(component: listComponent)
    controller.preloadView()

    let items = [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list")
    ]
    let expectation = self.expectation(description: "Test prepend items")
    controller.prepend(items, componentIndex: 0) {
      XCTAssertEqual(controller.components.first!.model.items.count, 2)
      XCTAssert(controller.components.first!.model.items == items)
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
    let listComponent = ListComponent(model: model)
    let controller = Controller(component: listComponent)

    controller.preloadView()

    let items = [
      Item(title: "title3", kind: "list"),
      Item(title: "title4", kind: "list")
    ]
    let expectation = self.expectation(description: "Test prepend items")
    controller.prepend(items, componentIndex: 0) {
      XCTAssertEqual(controller.components.first!.model.items.count, 4)
      XCTAssertEqual(controller.components.first!.model.items[0].title, "title3")
      XCTAssertEqual(controller.components.first!.model.items[1].title, "title4")
      XCTAssertEqual(controller.components.first!.model.items[2].title, "title1")
      XCTAssertEqual(controller.components.first!.model.items[3].title, "title2")
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
    let controller = Controller(component: initialListComponent)

    controller.preloadView()

    let firstItem = controller.components.first!.model.items.first

    XCTAssertEqual(firstItem?.title, "title1")
    XCTAssertEqual(firstItem?.index, 0)

    let expectation = self.expectation(description: "Test delete item")
    let listComponent = controller.components.first!
    listComponent.delete(model.items.first!) {
      let lastItem = controller.components.first!.model.items.first

      XCTAssertNotEqual(lastItem?.title, "title1")
      XCTAssertEqual(lastItem?.index, 0)
      XCTAssertEqual(lastItem?.title, "title2")
      XCTAssertEqual(controller.components.first!.model.items.count, 1)
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
    let controller = Controller(component: initialListComponent)

    controller.preloadView()

    let items = controller.components.first!.items
    let expectation = self.expectation(description: "Test delete items")

    controller.components[0].delete(items, withAnimation: .none) {
      XCTAssertEqual(controller.components.first!.model.items.count, 0)
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
    let controller = Controller(component: initialListComponent)

    controller.preloadView()

    let expectation = self.expectation(description: "Test delete items")

    controller.components[0].delete(1, withAnimation: .none) {
      XCTAssertEqual(controller.components.first!.model.items.count, 3)
      XCTAssertEqual(controller.components.first!.model.items[0].title, "title1")
      XCTAssertEqual(controller.components.first!.model.items[1].title, "title3")
      XCTAssertEqual(controller.components.first!.model.items[2].title, "title4")
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
    let controller = Controller(component: initialListComponent)

    controller.preloadView()

    let expectation = self.expectation(description: "Test delete items")

    controller.components[0].delete([1, 2], withAnimation: .none) {
      XCTAssertEqual(controller.components.first!.model.items.count, 2)
      XCTAssertEqual(controller.components.first!.model.items[0].title, "title1")
      XCTAssertEqual(controller.components.first!.model.items[1].title, "title4")
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendItemInGridComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "grid", span: 1.0)
    let listComponent = ListComponent(model: model)
    let controller = Controller(component: listComponent)

    controller.preloadView()

    XCTAssert(controller.components.first!.model.items.count == 0)

    let item = Item(title: "title1", kind: "grid")
    let expectation = self.expectation(description: "Test append item")

    controller.append(item, componentIndex: 0) {
      XCTAssert(controller.components.first!.model.items.count == 1)
      XCTAssert(controller.components.first!.model.items.first! == item)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendItemsInGridComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "grid", span: 1.0)
    let listComponent = ListComponent(model: model)
    let controller = Controller(component: listComponent)

    controller.preloadView()

    let items = [
      Item(title: "title1", kind: "grid"),
      Item(title: "title2", kind: "grid")
    ]
    let expectation = self.expectation(description: "Test append items")
    controller.append(items, componentIndex: 0) {
      XCTAssert(controller.components.first!.model.items.count > 0)
      XCTAssert(controller.components.first!.model.items == items)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testPrependItemsInGridComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "grid", span: 1.0)
    let listComponent = ListComponent(model: model)
    let controller = Controller(component: listComponent)

    controller.preloadView()

    let items = [
      Item(title: "title1", kind: "grid"),
      Item(title: "title2", kind: "grid")
    ]
    let expectation = self.expectation(description: "Test prepend items")
    controller.prepend(items, componentIndex: 0) {
      XCTAssertEqual(controller.components.first!.model.items.count, 2)
      XCTAssert(controller.components.first!.model.items == items)
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
    let controller = Controller(component: initialListComponent)

    controller.preloadView()

    let firstItem = controller.components.first!.model.items.first

    XCTAssertEqual(firstItem?.title, "title1")
    XCTAssertEqual(firstItem?.index, 0)

    let expectation = self.expectation(description: "Test delete item")
    let listComponent = controller.components.first!
    listComponent.delete(model.items.first!) {
      let lastItem = controller.components.first!.model.items.first

      XCTAssertNotEqual(lastItem?.title, "title1")
      XCTAssertEqual(lastItem?.index, 0)
      XCTAssertEqual(lastItem?.title, "title2")
      XCTAssertEqual(controller.components.first!.model.items.count, 1)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendItemInCarouselComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "carousel", span: 1.0)
    let listComponent = GridComponent(model: model)
    let controller = Controller(component: listComponent)

    controller.preloadView()

    XCTAssert(controller.components.first!.model.items.count == 0)

    let item = Item(title: "title1", kind: "carousel")
    let expectation = self.expectation(description: "Test append item")

    controller.append(item, componentIndex: 0) {
      XCTAssert(controller.components.first!.model.items.count == 1)
      XCTAssert(controller.components.first!.model.items.first! == item)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendItemsInCarouselComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "carousel", span: 1.0)
    let listComponent = GridComponent(model: model)
    let controller = Controller(component: listComponent)

    controller.preloadView()

    let items = [
      Item(title: "title1", kind: "carousel"),
      Item(title: "title2", kind: "carousel")
    ]
    let expectation = self.expectation(description: "Test append items")

    controller.append(items, componentIndex: 0) {
      XCTAssert(controller.components.first!.model.items.count > 0)
      XCTAssert(controller.components.first!.model.items == items)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testPrependItemsInCarouselComponent() {
    let model = ComponentModel(title: "ComponentModel", kind: "carousel", span: 1.0)
    let listComponent = ListComponent(model: model)
    let controller = Controller(component: listComponent)

    controller.preloadView()

    let items = [
      Item(title: "title1", kind: "carousel"),
      Item(title: "title2", kind: "carousel")
    ]
    let expectation = self.expectation(description: "Test prepend items")
    controller.prepend(items, componentIndex: 0) {
      XCTAssertEqual(controller.components.first!.model.items.count, 2)
      XCTAssert(controller.components.first!.model.items == items)
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
    let controller = Controller(component: initialListComponent)

    controller.preloadView()

    let firstItem = controller.components.first!.model.items.first

    XCTAssertEqual(firstItem?.title, "title1")
    XCTAssertEqual(firstItem?.index, 0)

    let expectation = self.expectation(description: "Test delete item")
    let listComponent = controller.components.first!
    listComponent.delete(model.items.first!) {
      let lastItem = controller.components.first!.model.items.first

      XCTAssertNotEqual(lastItem?.title, "title1")
      XCTAssertEqual(lastItem?.index, 0)
      XCTAssertEqual(lastItem?.title, "title2")
      XCTAssertEqual(controller.components.first!.model.items.count, 1)
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
    let listComponent = ListComponent(model: ComponentModel(title: "ListComponent", kind: "list", span: 1.0))
    let listComponent2 = ListComponent(model: ComponentModel(title: "ListComponent2", kind: "list", span: 1.0))
    let gridComponent = GridComponent(model: ComponentModel(title: "GridComponent", kind: "grid", span: 1.0, items: [Item(title: "Item")]))
    let controller = Controller(components: [listComponent, listComponent2, gridComponent])

    XCTAssertNotNil(controller.resolve(component: { $1.model.title == "ListComponent" }))
    XCTAssertNotNil(controller.resolve(component: { $1.model.title == "GridComponent" }))
    XCTAssertNotNil(controller.resolve(component: { $1.view is TableView }))
    XCTAssertNotNil(controller.resolve(component: { $1.view is CollectionView }))
    XCTAssertNotNil(controller.resolve(component: { $1.items.filter { $0.title == "Item" }.first != nil }))
    XCTAssertEqual(controller.resolve(component: { $0.0 == 0 })?.model.title, "ListComponent")
    XCTAssertEqual(controller.resolve(component: { $0.0 == 1 })?.model.title, "ListComponent2")
    XCTAssertEqual(controller.resolve(component: { $0.0 == 2 })?.model.title, "GridComponent")

    XCTAssertEqual(controller.filter(components: { $0.view is TableView }).count, 2)
    XCTAssertEqual(controller.filter(components: { $0.view is CollectionView }).count, 1)
  }

  func testJSONInitialiser() {
    let component = ListComponent(model: ComponentModel(kind: "list"))
    component.items = [Item(title: "First item")]
    let sourceController = Controller(component: component)
    let jsonController = Controller([
      "components": [
        ["kind": "list",
         "items": [
          ["title": "First item"]
          ]
        ]
      ]
      ])

    XCTAssert(sourceController.components.first!.model == jsonController.components.first!.model)
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

    XCTAssert(jsonController.components.first!.model.kind == "list")
    XCTAssert(jsonController.components.first!.model.items.count == 1)
    XCTAssert(jsonController.components.first!.model.items.first?.title == "First list item")

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
      XCTAssert(jsonController.components.first!.model.kind == "grid")
      XCTAssert(jsonController.components.first!.model.items.count == 2)
      XCTAssert(jsonController.components.first!.model.items.first?.title == "First grid item")
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

    XCTAssertTrue(firstController.components.first!.model == secondController.components.first!.model)
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
    XCTAssertTrue(controller.components[0] is ListComponent)
    XCTAssertEqual(controller.components[0].items.first?.title, "First list item")
    XCTAssertEqual(controller.components[1].items.first?.title, "First list item")
    XCTAssertTrue(controller.components[1] is ListComponent)
    XCTAssertTrue(controller.components.count == 2)
    XCTAssertTrue(controller.components[0].compositeComponents.count == 0)

    let expectation = self.expectation(description: "Reload multiple times with JSON (if needed)")

    controller.reloadIfNeeded(newJSON) {
      XCTAssertEqual(controller.components.count, 2)
      XCTAssertTrue(controller.components[0] is ListComponent)
      XCTAssertTrue(controller.components[1] is GridComponent)
      XCTAssertEqual(controller.components[0].items.first?.title, "First list item 2")
      XCTAssertEqual(controller.components[1].items.first?.title, "First list item")

      XCTAssertEqual(controller.components[0].items[1].kind, "composite")
      XCTAssertEqual(controller.components[0].compositeComponents.count, 1)

      controller.reloadIfNeeded(initialJSON) {
        XCTAssertTrue(controller.components[0] is ListComponent)
        XCTAssertEqual(controller.components[0].items.first?.title, "First list item")
        XCTAssertEqual(controller.components[1].items.first?.title, "First list item")
        XCTAssertTrue(controller.components[1] is ListComponent)
        XCTAssertTrue(controller.components.count == 2)
        XCTAssertTrue(controller.components[0].compositeComponents.count == 0)
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

    let components = initialComponentModels.map { Factory.resolve(model: $0) }
    let controller = Controller(components: components)

    let oldComponentModels: [ComponentModel] = controller.components.map { $0.model }

    let changes = controller.generateChanges(from: newComponentModels, and: oldComponentModels)
    XCTAssertEqual(changes.count, 1)
    XCTAssertEqual(changes.first, .items)

    /// Test what changed on the items
    let newItems = newComponentModels.first!.items
    let oldItems = controller.components.first!.items
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

    let components = initialComponentModels.map { Factory.resolve(model: $0) }

    /// Validate setting up a controller
    let controller = Controller(components: components)
    XCTAssertEqual(controller.components.count, 1)

    /// Test first item in the first component of the first component inside of the controller
    XCTAssertEqual(controller.components.first!.model.kind, components.first!.model.kind)
    XCTAssertEqual(controller.components.first!.model.items[0].title, components.first!.model.items[0].title)
    XCTAssertEqual(controller.components.first!.model.items[0].subtitle, components.first!.model.items[0].subtitle)
    XCTAssertEqual(controller.components.first!.model.items[0].kind, components.first!.model.items[0].kind)
    XCTAssertEqual(controller.components.first!.model.items[0].size, components.first!.model.items[0].size)

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
      controller.component(at: 0)?.tableView?.layoutMargins = UIEdgeInsets.zero
    #endif

    #if !os(OSX)
      view = controller.ui({ $0.kind == "image" })

      guard view != nil else {
        XCTFail("Unable to resolve view.")
        return
      }
    #endif

    XCTAssertEqual(controller.components.first!.model.items[0].title, initialComponentModels.first!.items[0].title)
    XCTAssertEqual(controller.components.first!.model.items[0].subtitle, initialComponentModels.first!.items[0].subtitle)
    XCTAssertEqual(controller.components.first!.model.items[0].action, initialComponentModels.first!.items[0].action)
    XCTAssertEqual(controller.components.first!.model.items[0].kind, initialComponentModels.first!.items[0].kind)
    XCTAssertNotEqual(controller.components.first!.model.items[0].size, initialComponentModels.first!.items[0].size)

    #if !os(OSX)
      XCTAssertEqual(controller.components.first!.model.items[0].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(controller.components.first!.model.items[0].size, view!.frame.size)
    #endif

    XCTAssertEqual(controller.components.first!.model.items[1].title, initialComponentModels.first!.items[1].title)
    XCTAssertEqual(controller.components.first!.model.items[1].subtitle, initialComponentModels.first!.items[1].subtitle)
    XCTAssertEqual(controller.components.first!.model.items[1].action, initialComponentModels.first!.items[1].action)
    XCTAssertEqual(controller.components.first!.model.items[1].kind, initialComponentModels.first!.items[1].kind)
    XCTAssertNotEqual(controller.components.first!.model.items[1].size, initialComponentModels.first!.items[1].size)
    #if !os(OSX)
      XCTAssertEqual(controller.components.first!.model.items[1].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(controller.components.first!.model.items[1].size, view!.frame.size)
    #endif

    XCTAssertEqual(controller.components.first!.model.items[2].title, initialComponentModels.first!.items[2].title)
    XCTAssertEqual(controller.components.first!.model.items[2].subtitle, initialComponentModels.first!.items[2].subtitle)
    XCTAssertEqual(controller.components.first!.model.items[2].action, initialComponentModels.first!.items[2].action)
    XCTAssertEqual(controller.components.first!.model.items[2].kind, initialComponentModels.first!.items[2].kind)
    XCTAssertNotEqual(controller.components.first!.model.items[2].size, initialComponentModels.first!.items[2].size)
    #if !os(OSX)
      XCTAssertEqual(controller.components.first!.model.items[2].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(controller.components.first!.model.items[2].size, view!.frame.size)
    #endif

    XCTAssertEqual(controller.components.first!.model.items[3].title, initialComponentModels.first!.items[3].title)
    XCTAssertEqual(controller.components.first!.model.items[3].subtitle, initialComponentModels.first!.items[3].subtitle)
    XCTAssertEqual(controller.components.first!.model.items[3].action, initialComponentModels.first!.items[3].action)
    XCTAssertEqual(controller.components.first!.model.items[3].kind, initialComponentModels.first!.items[3].kind)
    XCTAssertNotEqual(controller.components.first!.model.items[3].size, initialComponentModels.first!.items[3].size)

    #if !os(OSX)
      XCTAssertEqual(controller.components.first!.model.items[3].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(controller.components.first!.model.items[3].size, view!.frame.size)
    #endif

    XCTAssertEqual(controller.components.first!.model.items[4].title, initialComponentModels.first!.items[4].title)
    XCTAssertEqual(controller.components.first!.model.items[4].subtitle, initialComponentModels.first!.items[4].subtitle)
    XCTAssertEqual(controller.components.first!.model.items[4].action, initialComponentModels.first!.items[4].action)
    XCTAssertEqual(controller.components.first!.model.items[4].kind, initialComponentModels.first!.items[4].kind)
    XCTAssertNotEqual(controller.components.first!.model.items[4].size, initialComponentModels.first!.items[4].size)

    #if !os(OSX)
      XCTAssertEqual(controller.components.first!.model.items[4].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(controller.components.first!.model.items[4].size, view!.frame.size)
    #endif

    XCTAssertEqual(controller.components.first!.model.items[5].title, initialComponentModels.first!.items[5].title)
    XCTAssertEqual(controller.components.first!.model.items[5].subtitle, initialComponentModels.first!.items[5].subtitle)
    XCTAssertEqual(controller.components.first!.model.items[5].action, initialComponentModels.first!.items[5].action)
    XCTAssertEqual(controller.components.first!.model.items[5].kind, initialComponentModels.first!.items[5].kind)
    XCTAssertNotEqual(controller.components.first!.model.items[5].size, initialComponentModels.first!.items[5].size)

    #if !os(OSX)
      XCTAssertEqual(controller.components.first!.model.items[5].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
      XCTAssertEqual(controller.components.first!.model.items[5].size, view!.frame.size)
    #endif

    let expectation = self.expectation(description: "Reload controller with components")
    controller.reloadIfNeeded(newComponentModels) {
      XCTAssertEqual(controller.components.first!.model.items[0].title, newComponentModels.first!.items[0].title)
      XCTAssertEqual(controller.components.first!.model.items[0].subtitle, newComponentModels.first!.items[0].subtitle)
      XCTAssertEqual(controller.components.first!.model.items[0].action, newComponentModels.first!.items[0].action)
      XCTAssertEqual(controller.components.first!.model.items[0].kind, newComponentModels.first!.items[0].kind)
      XCTAssertNotEqual(controller.components.first!.model.items[0].size, newComponentModels.first!.items[0].size)
      #if !os(OSX)
        XCTAssertEqual(controller.components.first!.model.items[0].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
        XCTAssertEqual(controller.components.first!.model.items[0].size, view!.frame.size)
      #endif

      XCTAssertEqual(controller.components.first!.model.items[1].title, newComponentModels.first!.items[1].title)
      XCTAssertEqual(controller.components.first!.model.items[1].subtitle, newComponentModels.first!.items[1].subtitle)
      XCTAssertEqual(controller.components.first!.model.items[1].action, newComponentModels.first!.items[1].action)
      XCTAssertEqual(controller.components.first!.model.items[1].kind, newComponentModels.first!.items[1].kind)
      XCTAssertNotEqual(controller.components.first!.model.items[1].size, newComponentModels.first!.items[1].size)
      #if !os(OSX)
        XCTAssertEqual(controller.components.first!.model.items[1].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
        XCTAssertEqual(controller.components.first!.model.items[1].size, view!.frame.size)
      #endif

      XCTAssertEqual(controller.components.first!.model.items[2].title, newComponentModels.first!.items[2].title)
      XCTAssertEqual(controller.components.first!.model.items[2].subtitle, newComponentModels.first!.items[2].subtitle)
      XCTAssertEqual(controller.components.first!.model.items[2].action, newComponentModels.first!.items[2].action)
      XCTAssertEqual(controller.components.first!.model.items[2].kind, newComponentModels.first!.items[2].kind)
      XCTAssertNotEqual(controller.components.first!.model.items[2].size, newComponentModels.first!.items[2].size)
      #if !os(OSX)
        XCTAssertEqual(controller.components.first!.model.items[2].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
        XCTAssertEqual(controller.components.first!.model.items[2].size, view!.frame.size)
      #endif

      XCTAssertEqual(controller.components.first!.model.items[3].title, newComponentModels.first!.items[3].title)
      XCTAssertEqual(controller.components.first!.model.items[3].subtitle, newComponentModels.first!.items[3].subtitle)
      XCTAssertEqual(controller.components.first!.model.items[3].action, newComponentModels.first!.items[3].action)
      XCTAssertEqual(controller.components.first!.model.items[3].kind, newComponentModels.first!.items[3].kind)
      XCTAssertNotEqual(controller.components.first!.model.items[3].size, newComponentModels.first!.items[3].size)
      #if !os(OSX)
        XCTAssertEqual(controller.components.first!.model.items[3].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
        XCTAssertEqual(controller.components.first!.model.items[3].size, view!.frame.size)
      #endif

      XCTAssertEqual(controller.components.first!.model.items[4].title, newComponentModels.first!.items[4].title)
      XCTAssertEqual(controller.components.first!.model.items[4].subtitle, newComponentModels.first!.items[4].subtitle)
      XCTAssertEqual(controller.components.first!.model.items[4].action, newComponentModels.first!.items[4].action)
      XCTAssertEqual(controller.components.first!.model.items[4].kind, newComponentModels.first!.items[4].kind)
      XCTAssertNotEqual(controller.components.first!.model.items[4].size, newComponentModels.first!.items[4].size)
      #if !os(OSX)
        XCTAssertEqual(controller.components.first!.model.items[4].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
        XCTAssertEqual(controller.components.first!.model.items[4].size, view!.frame.size)
      #endif

      XCTAssertEqual(controller.components.first!.model.items[5].title, newComponentModels.first!.items[5].title)
      XCTAssertEqual(controller.components.first!.model.items[5].subtitle, newComponentModels.first!.items[5].subtitle)
      XCTAssertEqual(controller.components.first!.model.items[5].action, newComponentModels.first!.items[5].action)
      XCTAssertEqual(controller.components.first!.model.items[5].kind, newComponentModels.first!.items[5].kind)
      XCTAssertNotEqual(controller.components.first!.model.items[5].size, newComponentModels.first!.items[5].size)
      #if !os(OSX)
        XCTAssertEqual(controller.components.first!.model.items[5].size, CGSize(width: controller.view.frame.width, height: view!.preferredViewSize.height))
        XCTAssertEqual(controller.components.first!.model.items[5].size, view!.frame.size)
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

    let expectation = self.expectation(description: "Wait for componentsDidReloadComponentModels to be called")

    Controller.componentsDidReloadComponentModels = { controller in
      XCTAssert(true)
      expectation.fulfill()
    }

    let components = initialComponentModels.map { Factory.resolve(model: $0) }
    let controller = Controller(components: components)

    controller.prepareController()
    controller.reloadIfNeeded(newComponentModels)

    waitForExpectations(timeout: 10.0, handler: nil)
  }
}
