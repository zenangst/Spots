@testable import Spots
import Foundation
import XCTest

class ComponentDelegateMock: ComponentDelegate {}

class SpotsControllerTests: XCTestCase {

  override func setUp() {
    Configuration.views.purge()
  }

  func testSpotAtIndex() {
    let model = ComponentModel(layout: Layout(span: 1.0))
    let listComponent = Component(model: model)
    let controller = SpotsController(component: listComponent)
    controller.prepareController()

    XCTAssertEqual(controller.components.first, listComponent)
  }

  func testUpdateSpotAtIndex() {
    let model = ComponentModel(layout: Layout(span: 1.0))
    let listComponent = Component(model: model)
    let controller = SpotsController(component: listComponent)
    controller.prepareController()
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

  func testAppendItemInComponent() {
    let model = ComponentModel(kind: .list, layout: Layout(span: 1.0))
    let listComponent = Component(model: model)
    let controller = SpotsController(component: listComponent)
    controller.prepareController()

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

  func testAppendOneMoreItemInComponent() {
    let model = ComponentModel(kind: .list, items: [Item(title: "title1")])
    let listComponent = Component(model: model)
    let controller = SpotsController(component: listComponent)
    controller.prepareController()

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

  func testAppendItemsInComponent() {
    let model = ComponentModel(kind: .list, layout: Layout(span: 1.0))
    let listComponent = Component(model: model)
    let controller = SpotsController(component: listComponent)
    controller.prepareController()

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

  func testPrependItemsInComponent() {
    let model = ComponentModel(kind: .list, layout: Layout(span: 1.0))
    let listComponent = Component(model: model)
    let controller = SpotsController(component: listComponent)
    controller.prepareController()

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

  func testPrependMoreItemsInComponent() {
    let model = ComponentModel(kind: .list, layout: Layout(span: 1.0), items: [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list")
      ]
    )
    let listComponent = Component(model: model)
    let controller = SpotsController(component: listComponent)

    controller.prepareController()

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

  func testDeleteItemInComponent() {
    let model = ComponentModel(kind: .list, layout: Layout(span: 1.0), items: [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list")
      ])
    let initialListComponent = Component(model: model)
    let controller = SpotsController(component: initialListComponent)

    controller.prepareController()

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

  func testDeleteItemsInComponent() {
    let model = ComponentModel(kind: .list, layout: Layout(span: 1.0), items: [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list")
    ])
    let initialListComponent = Component(model: model)
    let controller = SpotsController(component: initialListComponent)

    controller.prepareController()

    let items = controller.components.first!.model.items
    let expectation = self.expectation(description: "Test delete items")

    controller.components[0].delete(items, withAnimation: .none) {
      XCTAssertEqual(controller.components.first!.model.items.count, 0)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testDeleteItemAtIndexInComponent() {
    let model = ComponentModel(kind: .list, layout: Layout(span: 1.0), items: [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list"),
      Item(title: "title3", kind: "list"),
      Item(title: "title4", kind: "list")
      ])
    let initialListComponent = Component(model: model)
    let controller = SpotsController(component: initialListComponent)

    controller.prepareController()

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

  func testDeleteItemsWithIndexesInComponent() {
    let model = ComponentModel(kind: .list, layout: Layout(span: 1.0), items: [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list"),
      Item(title: "title3", kind: "list"),
      Item(title: "title4", kind: "list")
      ])
    let initialListComponent = Component(model: model)
    let controller = SpotsController(component: initialListComponent)

    controller.prepareController()

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
    let model = ComponentModel(kind: .grid, layout: Layout(span: 1))
    let listComponent = Component(model: model)
    let controller = SpotsController(component: listComponent)

    controller.prepareController()

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
    let model = ComponentModel(kind: .grid, layout: Layout(span: 1))
    let listComponent = Component(model: model)
    let controller = SpotsController(component: listComponent)

    controller.prepareController()

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
    let model = ComponentModel(kind: .grid, layout: Layout(span: 1))
    let listComponent = Component(model: model)
    let controller = SpotsController(component: listComponent)

    controller.prepareController()

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
    let model = ComponentModel(kind: .grid, layout: Layout(span: 1), items: [
      Item(title: "title1", kind: "grid"),
      Item(title: "title2", kind: "grid")
      ])
    let initialListComponent = Component(model: model)
    let controller = SpotsController(component: initialListComponent)

    controller.prepareController()

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
    let model = ComponentModel(kind: .carousel, layout: Layout(span: 1.0))
    let listComponent = Component(model: model)
    let controller = SpotsController(component: listComponent)

    controller.prepareController()

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
    let model = ComponentModel(kind: .carousel, layout: Layout(span: 1.0))
    let listComponent = Component(model: model)
    let controller = SpotsController(component: listComponent)

    controller.prepareController()

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
    let model = ComponentModel(kind: .carousel, layout: Layout(span: 1.0))
    let listComponent = Component(model: model)
    let controller = SpotsController(component: listComponent)

    controller.prepareController()

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
    let model = ComponentModel(kind: .carousel, layout: Layout(span: 1.0), items: [
      Item(title: "title1", kind: "carousel"),
      Item(title: "title2", kind: "carousel")
      ])
    let initialListComponent = Component(model: model)
    let controller = SpotsController(component: initialListComponent)

    controller.prepareController()

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
    let model = ComponentModel(kind: .list, layout: Layout(span: 1.0), items: [
      Item(title: "title1", kind: "list"),
      Item(title: "title2", kind: "list")
      ])
    let component = Component(model: model)

    XCTAssert(component.model.items == model.items)

    let newItems = [Item(title: "title3", kind: "list")]
    component.model.items = newItems
    XCTAssertFalse(component.model.items == model.items)
    XCTAssert(component.model.items == newItems)
  }

  func testFindAndFilterComponentWithClosure() {
    let listComponent = Component(model: ComponentModel(identifier: "ListComponent", kind: .list, layout: Layout(span: 1.0)))
    let listComponent2 = Component(model: ComponentModel(identifier: "ListComponent2", kind: .list, layout: Layout(span: 1.0)))
    let gridComponent = Component(model: ComponentModel(identifier: "GridComponent", kind: .grid, layout: Layout(span: 1.0), items: [Item(title: "Item")]))
    let controller = SpotsController(components: [listComponent, listComponent2, gridComponent])

    XCTAssertNotNil(controller.resolve(component: { $1.model.identifier == "ListComponent" }))
    XCTAssertNotNil(controller.resolve(component: { $1.model.identifier == "GridComponent" }))
    XCTAssertNotNil(controller.resolve(component: { $1.userInterface is TableView }))
    XCTAssertNotNil(controller.resolve(component: { $1.userInterface is CollectionView }))
    XCTAssertNotNil(controller.resolve(component: { $1.model.items.filter { $0.title == "Item" }.first != nil }))
    XCTAssertEqual(controller.resolve(component: { $0.0 == 0 })?.model.identifier, "ListComponent")
    XCTAssertEqual(controller.resolve(component: { $0.0 == 1 })?.model.identifier, "ListComponent2")
    XCTAssertEqual(controller.resolve(component: { $0.0 == 2 })?.model.identifier, "GridComponent")

    XCTAssertEqual(controller.filter(components: { $0.userInterface is TableView }).count, 2)
    XCTAssertEqual(controller.filter(components: { $0.userInterface is CollectionView }).count, 1)
  }

  func testJSONInitialiser() {
    let component = Component(model: ComponentModel(kind: .list))
    component.model.items = [Item(title: "First item")]
    let sourceController = SpotsController(component: component)
    let jsonController = SpotsController([
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
    let jsonController = SpotsController(initialJSON)

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
    let firstController = SpotsController(initialJSON)
    let secondController = SpotsController(firstController.dictionary)

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
            "kind": CompositeComponent.identifier,
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

    let controller = SpotsController(initialJSON)
    XCTAssertTrue(controller.components[0].userInterface is TableView)
    XCTAssertEqual(controller.components[0].model.items.first?.title, "First list item")
    XCTAssertEqual(controller.components[1].model.items.first?.title, "First list item")
    XCTAssertTrue(controller.components[1].userInterface is TableView)
    XCTAssertTrue(controller.components.count == 2)
    XCTAssertTrue(controller.components[0].compositeComponents.count == 0)

    let expectation = self.expectation(description: "Reload multiple times with JSON (if needed)")

    controller.reloadIfNeeded(newJSON) {
      XCTAssertEqual(controller.components.count, 2)
      XCTAssertTrue(controller.components[0].userInterface is TableView)
      XCTAssertTrue(controller.components[1].userInterface is CollectionView)
      XCTAssertEqual(controller.components[0].model.items.first?.title, "First list item 2")
      XCTAssertEqual(controller.components[1].model.items.first?.title, "First list item")

      XCTAssertEqual(controller.components[0].model.items[1].kind, CompositeComponent.identifier)
      XCTAssertEqual(controller.components[0].compositeComponents.count, 1)

      controller.reloadIfNeeded(initialJSON) {
        XCTAssertTrue(controller.components[0].userInterface is TableView)
        XCTAssertEqual(controller.components[0].model.items.first?.title, "First list item")
        XCTAssertEqual(controller.components[1].model.items.first?.title, "First list item")
        XCTAssertTrue(controller.components[1].userInterface is TableView)
        XCTAssertTrue(controller.components.count == 2)
        XCTAssertTrue(controller.components[0].compositeComponents.count == 0)
        expectation.fulfill()
      }
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testReloadIfNeededWithComponentModels() {
    Configuration.registerDefault(view: DefaultItemView.self)
    Configuration.defaultViewSize = .init(width: 0, height: 44)
    let initialComponentModels = [
      ComponentModel(
        kind: .list,
        layout: Layout(span: 1.0),
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
        kind: .list,
        layout: Layout(span: 1.0),
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

    let components = initialComponentModels.map { Component(model: $0) }

    /// Validate setting up a controller
    let controller = SpotsController(components: components)
    XCTAssertEqual(controller.components.count, 1)

    /// Test first item in the first component of the first component inside of the controller
    XCTAssertEqual(controller.components.first!.model.kind, components.first!.model.kind)
    XCTAssertEqual(controller.components.first!.model.items[0].title, components.first!.model.items[0].title)
    XCTAssertEqual(controller.components.first!.model.items[0].subtitle, components.first!.model.items[0].subtitle)
    XCTAssertEqual(controller.components.first!.model.items[0].kind, components.first!.model.items[0].kind)
    XCTAssertEqual(controller.components.first!.model.items[0].size, components.first!.model.items[0].size)

    XCTAssertTrue(initialComponentModels !== newComponentModels)
    XCTAssertEqual(initialComponentModels.count, newComponentModels.count)

    var view: DefaultItemView? = controller.ui({ $0.kind == "image" })
    XCTAssertNil(view)

    controller.prepareController()
    let firstComponent = controller.components.first!

    /// Reset layout margins for tvOS
    #if os(tvOS)
      controller.component(at: 0)?.tableView?.layoutMargins = .zero
    #endif

    #if !os(OSX)
      view = controller.ui({ $0.kind == "image" })

      guard view != nil else {
        XCTFail("Unable to resolve view.")
        return
      }

      let expectedFrame = view!.frame
    #endif

    XCTAssertEqual(firstComponent.model.items[0].title, initialComponentModels.first!.items[0].title)
    XCTAssertEqual(firstComponent.model.items[0].subtitle, initialComponentModels.first!.items[0].subtitle)
    XCTAssertEqual(firstComponent.model.items[0].action, initialComponentModels.first!.items[0].action)
    XCTAssertEqual(firstComponent.model.items[0].kind, initialComponentModels.first!.items[0].kind)
    XCTAssertNotEqual(firstComponent.model.items[0].size, initialComponentModels.first!.items[0].size)

    #if !os(OSX)
      XCTAssertEqual(firstComponent.model.items[0].size, CGSize(width: controller.view.frame.width, height: view!.computeSize(for: firstComponent.model.items[0], containerSize: firstComponent.view.frame.size).height))
      XCTAssertEqual(firstComponent.model.items[0].size, view!.frame.size)
    #endif

    XCTAssertEqual(firstComponent.model.items[1].title, initialComponentModels.first!.items[1].title)
    XCTAssertEqual(firstComponent.model.items[1].subtitle, initialComponentModels.first!.items[1].subtitle)
    XCTAssertEqual(firstComponent.model.items[1].action, initialComponentModels.first!.items[1].action)
    XCTAssertEqual(firstComponent.model.items[1].kind, initialComponentModels.first!.items[1].kind)
    XCTAssertNotEqual(firstComponent.model.items[1].size, initialComponentModels.first!.items[1].size)
    #if !os(OSX)
      XCTAssertEqual(firstComponent.model.items[1].size, CGSize(width: controller.view.frame.width, height: view!.computeSize(for: firstComponent.model.items[1], containerSize: firstComponent.view.frame.size).height))
      XCTAssertEqual(firstComponent.model.items[1].size, view!.frame.size)
    #endif

    XCTAssertEqual(firstComponent.model.items[2].title, initialComponentModels.first!.items[2].title)
    XCTAssertEqual(firstComponent.model.items[2].subtitle, initialComponentModels.first!.items[2].subtitle)
    XCTAssertEqual(firstComponent.model.items[2].action, initialComponentModels.first!.items[2].action)
    XCTAssertEqual(firstComponent.model.items[2].kind, initialComponentModels.first!.items[2].kind)
    XCTAssertNotEqual(firstComponent.model.items[2].size, initialComponentModels.first!.items[2].size)
    #if !os(OSX)
      XCTAssertEqual(firstComponent.model.items[2].size, CGSize(width: controller.view.frame.width, height: view!.computeSize(for: firstComponent.model.items[2], containerSize: firstComponent.view.frame.size).height))
      XCTAssertEqual(firstComponent.model.items[2].size, view!.frame.size)
    #endif

    XCTAssertEqual(firstComponent.model.items[3].title, initialComponentModels.first!.items[3].title)
    XCTAssertEqual(firstComponent.model.items[3].subtitle, initialComponentModels.first!.items[3].subtitle)
    XCTAssertEqual(firstComponent.model.items[3].action, initialComponentModels.first!.items[3].action)
    XCTAssertEqual(firstComponent.model.items[3].kind, initialComponentModels.first!.items[3].kind)
    XCTAssertNotEqual(firstComponent.model.items[3].size, initialComponentModels.first!.items[3].size)

    #if !os(OSX)
      XCTAssertEqual(firstComponent.model.items[3].size, CGSize(width: controller.view.frame.width, height: view!.computeSize(for: firstComponent.model.items[3], containerSize: firstComponent.view.frame.size).height))
      XCTAssertEqual(firstComponent.model.items[3].size, view!.frame.size)
    #endif

    XCTAssertEqual(firstComponent.model.items[4].title, initialComponentModels.first!.items[4].title)
    XCTAssertEqual(firstComponent.model.items[4].subtitle, initialComponentModels.first!.items[4].subtitle)
    XCTAssertEqual(firstComponent.model.items[4].action, initialComponentModels.first!.items[4].action)
    XCTAssertEqual(firstComponent.model.items[4].kind, initialComponentModels.first!.items[4].kind)
    XCTAssertNotEqual(firstComponent.model.items[4].size, initialComponentModels.first!.items[4].size)

    #if !os(OSX)
      XCTAssertEqual(firstComponent.model.items[4].size, CGSize(width: controller.view.frame.width, height: view!.computeSize(for: firstComponent.model.items[4], containerSize: firstComponent.view.frame.size).height))
      XCTAssertEqual(firstComponent.model.items[4].size, view!.frame.size)
    #endif

    XCTAssertEqual(firstComponent.model.items[5].title, initialComponentModels.first!.items[5].title)
    XCTAssertEqual(firstComponent.model.items[5].subtitle, initialComponentModels.first!.items[5].subtitle)
    XCTAssertEqual(firstComponent.model.items[5].action, initialComponentModels.first!.items[5].action)
    XCTAssertEqual(firstComponent.model.items[5].kind, initialComponentModels.first!.items[5].kind)
    XCTAssertNotEqual(firstComponent.model.items[5].size, initialComponentModels.first!.items[5].size)

    #if !os(OSX)
      XCTAssertEqual(firstComponent.model.items[5].size, CGSize(width: controller.view.frame.width, height: view!.computeSize(for: firstComponent.model.items[5], containerSize: firstComponent.view.frame.size).height))
      XCTAssertEqual(firstComponent.model.items[5].size, view!.frame.size)
    #endif

    let expectation = self.expectation(description: "Reload controller with components")
    controller.reloadIfNeeded(newComponentModels) {
      XCTAssertEqual(firstComponent.model.items[0].title, newComponentModels.first!.items[0].title)
      XCTAssertEqual(firstComponent.model.items[0].subtitle, newComponentModels.first!.items[0].subtitle)
      XCTAssertEqual(firstComponent.model.items[0].action, newComponentModels.first!.items[0].action)
      XCTAssertEqual(firstComponent.model.items[0].kind, newComponentModels.first!.items[0].kind)
      XCTAssertNotEqual(firstComponent.model.items[0].size, newComponentModels.first!.items[0].size)
      #if !os(OSX)
        XCTAssertEqual(firstComponent.model.items[0].size, CGSize(width: controller.view.frame.width, height: view!.computeSize(for: firstComponent.model.items[0], containerSize: firstComponent.view.frame.size).height))
        XCTAssertEqual(firstComponent.model.items[0].size, expectedFrame.size)
      #endif

      XCTAssertEqual(firstComponent.model.items[1].title, newComponentModels.first!.items[1].title)
      XCTAssertEqual(firstComponent.model.items[1].subtitle, newComponentModels.first!.items[1].subtitle)
      XCTAssertEqual(firstComponent.model.items[1].action, newComponentModels.first!.items[1].action)
      XCTAssertEqual(firstComponent.model.items[1].kind, newComponentModels.first!.items[1].kind)
      XCTAssertNotEqual(firstComponent.model.items[1].size, newComponentModels.first!.items[1].size)
      #if !os(OSX)
        XCTAssertEqual(firstComponent.model.items[1].size, CGSize(width: controller.view.frame.width, height: view!.computeSize(for: firstComponent.model.items[1], containerSize: firstComponent.view.frame.size).height))
        XCTAssertEqual(firstComponent.model.items[1].size, expectedFrame.size)
      #endif

      XCTAssertEqual(firstComponent.model.items[2].title, newComponentModels.first!.items[2].title)
      XCTAssertEqual(firstComponent.model.items[2].subtitle, newComponentModels.first!.items[2].subtitle)
      XCTAssertEqual(firstComponent.model.items[2].action, newComponentModels.first!.items[2].action)
      XCTAssertEqual(firstComponent.model.items[2].kind, newComponentModels.first!.items[2].kind)
      XCTAssertNotEqual(firstComponent.model.items[2].size, newComponentModels.first!.items[2].size)
      #if !os(OSX)
        XCTAssertEqual(firstComponent.model.items[2].size, CGSize(width: controller.view.frame.width, height: view!.computeSize(for: firstComponent.model.items[2], containerSize: firstComponent.view.frame.size).height))
        XCTAssertEqual(firstComponent.model.items[2].size, expectedFrame.size)
      #endif

      XCTAssertEqual(firstComponent.model.items[3].title, newComponentModels.first!.items[3].title)
      XCTAssertEqual(firstComponent.model.items[3].subtitle, newComponentModels.first!.items[3].subtitle)
      XCTAssertEqual(firstComponent.model.items[3].action, newComponentModels.first!.items[3].action)
      XCTAssertEqual(firstComponent.model.items[3].kind, newComponentModels.first!.items[3].kind)
      XCTAssertNotEqual(firstComponent.model.items[3].size, newComponentModels.first!.items[3].size)
      #if !os(OSX)
        XCTAssertEqual(firstComponent.model.items[3].size, CGSize(width: controller.view.frame.width, height: view!.computeSize(for: firstComponent.model.items[3], containerSize: firstComponent.view.frame.size).height))
        XCTAssertEqual(firstComponent.model.items[3].size, expectedFrame.size)
      #endif

      XCTAssertEqual(firstComponent.model.items[4].title, newComponentModels.first!.items[4].title)
      XCTAssertEqual(firstComponent.model.items[4].subtitle, newComponentModels.first!.items[4].subtitle)
      XCTAssertEqual(firstComponent.model.items[4].action, newComponentModels.first!.items[4].action)
      XCTAssertEqual(firstComponent.model.items[4].kind, newComponentModels.first!.items[4].kind)
      XCTAssertNotEqual(firstComponent.model.items[4].size, newComponentModels.first!.items[4].size)
      #if !os(OSX)
        XCTAssertEqual(firstComponent.model.items[4].size, CGSize(width: controller.view.frame.width, height: view!.computeSize(for: firstComponent.model.items[4], containerSize: firstComponent.view.frame.size).height))
        XCTAssertEqual(firstComponent.model.items[4].size, expectedFrame.size)
      #endif

      XCTAssertEqual(firstComponent.model.items[5].title, newComponentModels.first!.items[5].title)
      XCTAssertEqual(firstComponent.model.items[5].subtitle, newComponentModels.first!.items[5].subtitle)
      XCTAssertEqual(firstComponent.model.items[5].action, newComponentModels.first!.items[5].action)
      XCTAssertEqual(firstComponent.model.items[5].kind, newComponentModels.first!.items[5].kind)
      XCTAssertNotEqual(firstComponent.model.items[5].size, newComponentModels.first!.items[5].size)
      #if !os(OSX)
        XCTAssertEqual(firstComponent.model.items[5].size, CGSize(width: controller.view.frame.width, height: view!.computeSize(for: firstComponent.model.items[5], containerSize: firstComponent.view.frame.size).height))
        XCTAssertEqual(firstComponent.model.items[5].size, expectedFrame.size)
      #endif

      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testReloadWithComponentModels() {
    let controller = SpotsController(components: [])
    let expectation = self.expectation(description: "Wait reload to complete")
    let models = [
      ComponentModel(header: Item(title: "foo")),
      ComponentModel(items: [Item(title: "bar")]),
      ComponentModel(footer: Item(title: "baz"))
    ]

    controller.reload(models) {
      XCTAssertEqual(controller.components.count, 3)
      XCTAssertTrue(controller.components[0].model.header! == Item(title: "foo"))
      XCTAssertTrue(controller.components[1].model.items   == [Item(title: "bar")])
      XCTAssertTrue(controller.components[2].model.footer! == Item(title: "baz"))
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testComponentAtIndex() {
    let listModel = ComponentModel(kind: .list)
    let gridModel = ComponentModel(kind: .grid)
    let listComponent = Component(model: listModel)
    let gridComponent = Component(model: gridModel)
    let controller = SpotsController(components: [listComponent, gridComponent])

    XCTAssertEqual(controller.component(at: 0), listComponent)
    XCTAssertEqual(controller.component(at: 1), gridComponent)
    XCTAssertEqual(controller.component(at: 2), nil)
  }

  func testUpdatingDelegates() {
    let listModel = ComponentModel(kind: .list)
    let gridModel = ComponentModel(kind: .grid)
    let listComponent = Component(model: listModel)
    let gridComponent = Component(model: gridModel)
    let controller = SpotsController(components: [listComponent, gridComponent])
    let mockDelegate = ComponentDelegateMock()
    controller.delegate = mockDelegate

    XCTAssertTrue(mockDelegate === listComponent.delegate!)
    XCTAssertTrue(mockDelegate === gridComponent.delegate!)
  }
}
