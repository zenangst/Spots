import XCTest
import Spots

class TestSpotsControllerManager: XCTestCase {

  let component = Component(model: ComponentModel(kind: .list, items: [
    Item(title: "foo"),
    Item(title: "bar"),
    Item(title: "baz")
    ]))

  override func setUp() {
    Configuration.registerDefault(view: TestView.self)
  }

  func testAppendItem() {
    let expectation = self.expectation(description: "Wait for completion")
    let controller = SpotsController(components: [component])
    controller.prepareController()
    controller.append(Item(title: "baz1")) {
      XCTAssertTrue(controller.components.first!.model.items == [
        Item(title: "foo"),
        Item(title: "bar"),
        Item(title: "baz"),
        Item(title: "baz1")
        ])

      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendItems() {
    let expectation = self.expectation(description: "Wait for completion")
    let items = [
      Item(title: "baz1"),
      Item(title: "baz2")
    ]
    let controller = SpotsController(components: [component])
    controller.prepareController()
    controller.append(items) {
      XCTAssertTrue(controller.components.first!.model.items == [
        Item(title: "foo"),
        Item(title: "bar"),
        Item(title: "baz"),
        Item(title: "baz1"),
        Item(title: "baz2")
        ])

      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testPrependItems() {
    let expectation = self.expectation(description: "Wait for completion")
    let items = [
      Item(title: "baz1"),
      Item(title: "baz2")
    ]
    let controller = SpotsController(components: [component])
    controller.prepareController()
    controller.prepend(items) {
      XCTAssertTrue(controller.components.first!.model.items == [
        Item(title: "baz1"),
        Item(title: "baz2"),
        Item(title: "foo"),
        Item(title: "bar"),
        Item(title: "baz")
        ])

      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testInsertItem() {
    let expectation = self.expectation(description: "Wait for completion")
    let controller = SpotsController(components: [component])
    controller.prepareController()
    controller.insert(Item(title: "baz1"), index: 1, componentIndex: 0) {
      XCTAssertTrue(controller.components.first!.model.items == [
        Item(title: "foo"),
        Item(title: "baz1"),
        Item(title: "bar"),
        Item(title: "baz")
        ])

      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testUpdateItem() {
    let expectation = self.expectation(description: "Wait for completion")
    let controller = SpotsController(components: [component])
    controller.prepareController()
    controller.update(Item(title: "baz1"), index: 2, componentIndex: 0) {
      XCTAssertTrue(controller.components.first!.model.items == [
        Item(title: "foo"),
        Item(title: "bar"),
        Item(title: "baz1")
        ])

      controller.update(Item(title: "baz1"), index: 2, componentIndex: 0) {
        XCTAssertTrue(controller.components.first!.model.items == [
          Item(title: "foo"),
          Item(title: "bar"),
          Item(title: "baz1")
          ])
        expectation.fulfill()
      }
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testUpdateItemsWithIndexes() {
    let expectation = self.expectation(description: "Wait for completion")
    let controller = SpotsController(components: [component])
    controller.prepareController()
    controller.components[0].model.items[0] = Item(title: "foo1")
    controller.components[0].model.items[1] = Item(title: "bar1")

    controller.update([0,1], componentIndex: 0) {
      XCTAssertTrue(controller.components.first!.model.items == [
        Item(title: "foo1"),
        Item(title: "bar1"),
        Item(title: "baz")
        ])

      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testDeleteItem() {
    let expectation = self.expectation(description: "Wait for completion")
    let controller = SpotsController(components: [component])
    controller.prepareController()
    controller.delete(1) {
      XCTAssertTrue(controller.components.first!.model.items == [
        Item(title: "foo"),
        Item(title: "baz")
        ])

      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }


  func testDeleteItems() {
    let expectation = self.expectation(description: "Wait for completion")
    let controller = SpotsController(components: [component])
    controller.prepareController()
    controller.delete([0,2]) {
      XCTAssertTrue(controller.components.first!.model.items == [
        Item(title: "bar")
        ])

      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testUpdateIfNeeded() {
    let items = [
      Item(title: "baz1"),
      Item(title: "baz2")
    ]

    let controller = SpotsController(components: [component])
    let expectation = self.expectation(description: "Wait for completion")
    controller.updateIfNeeded(componentAtIndex: 0, items: items) {
      XCTAssertTrue(controller.components.first!.model.items == [
        Item(title: "baz1"),
        Item(title: "baz2")
        ])

      controller.updateIfNeeded(componentAtIndex: 0, items: items) {
        XCTAssertTrue(controller.components.first!.model.items == [
          Item(title: "baz1"),
          Item(title: "baz2")
          ])
        expectation.fulfill()
      }
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testReloadController() {
    let expectation = self.expectation(description: "Wait for completion")
    let controller = SpotsController(components: [component])
    controller.prepareController()
    controller.reload() {
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testReloadIfNeededWithComponents() {
    let initialModels = [
      ComponentModel(kind: .carousel, layout: Layout(span: 1.0), items: [
        Item(title: "foo1"),
        Item(title: "bar1"),
        Item(title: "baz1")
        ]
      ),
      ComponentModel(kind: .grid, layout: Layout(span: 3.0), items: [
        Item(title: "foo2"),
        Item(title: "bar2"),
        Item(title: "baz2")
        ]
      ),
      ComponentModel(kind: .list, items: [
        Item(title: "foo3"),
        Item(title: "bar3"),
        Item(title: "baz3")
        ]
      )
    ]

    let updatedModels = [
      ComponentModel(kind: .carousel, layout: Layout(span: 1.0), items: [
        Item(title: "foo1"),
        Item(title: "bar4")
        ]
      ),
      ComponentModel(kind: .carousel, layout: Layout(span: 3.0), items: [
        Item(title: "foo2"),
        Item(title: "bar2"),
        Item(title: "baz2"),
        Item(title: "baz4")
        ]
      ),
      ComponentModel(kind: .list, items: [
        Item(title: "foo3"),
        Item(title: "bar3"),
        Item(title: "baz3")
        ]
      )
    ]

    let finalUpdate = [
      ComponentModel(kind: .carousel, layout: Layout(span: 1.0), items: [
        Item(title: "foo1"),
        Item(title: "bar4")
        ]
      ),
      ComponentModel(kind: .list, items: [
        Item(title: "foo3"),
        Item(title: "bar3"),
        Item(title: "baz3")
        ]
      )
    ]

    var expectation: XCTestExpectation? = self.expectation(description: "Wait for completion")

    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    let model = ComponentModel(kind: .list, items: items)
    let component = Component(model: model)
    let controller = SpotsController(components: [component])

    controller.reloadIfNeeded([]) {
      XCTAssertTrue(controller.components.isEmpty)

      controller.reloadIfNeeded(initialModels) {

        XCTAssertEqual(controller.components.count, 3)

        XCTAssertNotNil(controller.components[0].collectionView)
        XCTAssertNotNil(controller.components[1].collectionView)
        XCTAssertNotNil(controller.components[2].tableView)

        XCTAssertEqual(controller.components[0].model.items[0].title, "foo1")
        XCTAssertEqual(controller.components[0].model.items[1].title, "bar1")
        XCTAssertEqual(controller.components[0].model.items[2].title, "baz1")

        XCTAssertEqual(controller.components[1].model.items[0].title, "foo2")
        XCTAssertEqual(controller.components[1].model.items[1].title, "bar2")
        XCTAssertEqual(controller.components[1].model.items[2].title, "baz2")

        XCTAssertEqual(controller.components[2].model.items[0].title, "foo3")
        XCTAssertEqual(controller.components[2].model.items[1].title, "bar3")
        XCTAssertEqual(controller.components[2].model.items[2].title, "baz3")

        var carouselInstance = controller.components[0].collectionView
        var gridInstance = controller.components[1].collectionView
        var listInstance = controller.components[2].tableView

        controller.reloadIfNeeded(updatedModels) {
          XCTAssertEqual(controller.components.count, 3)

          XCTAssertNotNil(controller.components[0].collectionView)
          XCTAssertNotNil(controller.components[1].collectionView)
          XCTAssertNotNil(controller.components[2].tableView)

          XCTAssertEqual(controller.components[0].model.items[0].title, "foo1")
          XCTAssertEqual(controller.components[0].model.items[1].title, "bar4")

          XCTAssertEqual(controller.components[1].model.items[0].title, "foo2")
          XCTAssertEqual(controller.components[1].model.items[1].title, "bar2")
          XCTAssertEqual(controller.components[1].model.items[2].title, "baz2")
          XCTAssertEqual(controller.components[1].model.items[3].title, "baz4")

          XCTAssertEqual(controller.components[2].model.items[0].title, "foo3")
          XCTAssertEqual(controller.components[2].model.items[1].title, "bar3")
          XCTAssertEqual(controller.components[2].model.items[2].title, "baz3")

          XCTAssertEqual(carouselInstance, controller.components[0].collectionView)
          XCTAssertNotEqual(gridInstance, controller.components[1].collectionView)
          XCTAssertEqual(listInstance, controller.components[2].tableView)

          carouselInstance = controller.components[0].collectionView
          gridInstance = controller.components[1].collectionView
          listInstance = controller.components[2].tableView

          controller.reloadIfNeeded(updatedModels) {
            XCTAssertEqual(controller.components.count, 3)

            XCTAssertNotNil(controller.components[0].collectionView)
            XCTAssertNotNil(controller.components[1].collectionView)
            XCTAssertNotNil(controller.components[2].tableView)

            XCTAssertEqual(controller.components[0].model.items[0].title, "foo1")
            XCTAssertEqual(controller.components[0].model.items[1].title, "bar4")

            XCTAssertEqual(controller.components[1].model.items[0].title, "foo2")
            XCTAssertEqual(controller.components[1].model.items[1].title, "bar2")
            XCTAssertEqual(controller.components[1].model.items[2].title, "baz2")
            XCTAssertEqual(controller.components[1].model.items[3].title, "baz4")

            XCTAssertEqual(controller.components[2].model.items[0].title, "foo3")
            XCTAssertEqual(controller.components[2].model.items[1].title, "bar3")
            XCTAssertEqual(controller.components[2].model.items[2].title, "baz3")

            XCTAssertEqual(carouselInstance, controller.components[0].collectionView)
            XCTAssertEqual(gridInstance, controller.components[1].collectionView)
            XCTAssertEqual(listInstance, controller.components[2].tableView)

            controller.reloadIfNeeded(finalUpdate) {

              guard expectation != nil else {
                XCTFail("Exception is nil")
                return
              }

              XCTAssertEqual(controller.components.count, 2)

              XCTAssertNotNil(controller.components[0].collectionView)
              XCTAssertNotNil(controller.components[1].tableView)

              XCTAssertEqual(controller.components[0].model.items[0].title, "foo1")
              XCTAssertEqual(controller.components[0].model.items[1].title, "bar4")

              XCTAssertEqual(controller.components[1].model.items[0].title, "foo3")
              XCTAssertEqual(controller.components[1].model.items[1].title, "bar3")
              XCTAssertEqual(controller.components[1].model.items[2].title, "baz3")

              XCTAssertEqual(carouselInstance, controller.components[0].collectionView)
              XCTAssertNotEqual(listInstance, controller.components[1].tableView)

              expectation?.fulfill()
              expectation = nil
            }
          }
        }
      }
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testSpotsDidReloadComponentModels() {
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

    let expectation = self.expectation(description: "Wait for componentsDidReloadComponentModels to be called")

    SpotsController.componentsDidReloadComponentModels = { controller in
      XCTAssert(true)
      expectation.fulfill()
    }

    let components = initialComponentModels.map { Component(model: $0) }
    let controller = SpotsController(components: components)

    controller.prepareController()
    controller.reloadIfNeeded(newComponentModels)

    waitForExpectations(timeout: 10.0, handler: nil)
  }
}
