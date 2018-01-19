import XCTest
import Spots

class SpotsControllerManagerTests: XCTestCase {

  var controller: SpotsController!
  let component = Component(model: ComponentModel(kind: .list, items: [
    Item(title: "foo"),
    Item(title: "bar"),
    Item(title: "baz")
    ]))

  override func setUp() {
    Configuration.shared.registerDefault(view: TestView.self)

    controller = SpotsController(components: [component])
    controller.prepareController()
  }

  func testAppendItem() {
    let expectation = self.expectation(description: "Wait for completion")
    controller.append(Item(title: "baz1")) {
      XCTAssertTrue(self.controller.components.first!.model.items == [
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

    controller.append(items) {
      XCTAssertTrue(self.controller.components.first!.model.items == [
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
    controller.prepend(items) {
      XCTAssertTrue(self.controller.components.first!.model.items == [
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
    controller.insert(Item(title: "baz1"), index: 1, componentIndex: 0) {
      XCTAssertTrue(self.controller.components.first!.model.items == [
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
    controller.update(Item(title: "baz1"), index: 2, componentIndex: 0) {
      XCTAssertTrue(self.controller.components.first!.model.items == [
        Item(title: "foo"),
        Item(title: "bar"),
        Item(title: "baz1")
        ])

      self.controller.update(Item(title: "baz1"), index: 2, componentIndex: 0) {
        XCTAssertTrue(self.controller.components.first!.model.items == [
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
    controller.components[0].model.items[0] = Item(title: "foo1")
    controller.components[0].model.items[1] = Item(title: "bar1")

    controller.update([0,1], componentIndex: 0) {
      XCTAssertTrue(self.controller.components.first!.model.items == [
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
    controller.delete(1) {
      XCTAssertTrue(self.controller.components.first!.model.items == [
        Item(title: "foo"),
        Item(title: "baz")
        ])

      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }


  func testDeleteItems() {
    let expectation = self.expectation(description: "Wait for completion")
    controller.delete([0,2]) {
      XCTAssertTrue(self.controller.components.first!.model.items == [
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

    controller.reloadIfNeeded([]) {
      XCTAssertTrue(self.controller.components.isEmpty)

      self.controller.reloadIfNeeded(initialModels) {

        XCTAssertEqual(self.controller.components.count, 3)

        XCTAssertNotNil(self.controller.components[0].collectionView)
        XCTAssertNotNil(self.controller.components[1].collectionView)
        XCTAssertNotNil(self.controller.components[2].tableView)

        XCTAssertEqual(self.controller.components[0].model.items[0].title, "foo1")
        XCTAssertEqual(self.controller.components[0].model.items[1].title, "bar1")
        XCTAssertEqual(self.controller.components[0].model.items[2].title, "baz1")

        XCTAssertEqual(self.controller.components[1].model.items[0].title, "foo2")
        XCTAssertEqual(self.controller.components[1].model.items[1].title, "bar2")
        XCTAssertEqual(self.controller.components[1].model.items[2].title, "baz2")

        XCTAssertEqual(self.controller.components[2].model.items[0].title, "foo3")
        XCTAssertEqual(self.controller.components[2].model.items[1].title, "bar3")
        XCTAssertEqual(self.controller.components[2].model.items[2].title, "baz3")

        var carouselInstance = self.controller.components[0].collectionView
        var gridInstance = self.controller.components[1].collectionView
        var listInstance = self.controller.components[2].tableView

        self.controller.reloadIfNeeded(updatedModels) {
          XCTAssertEqual(self.controller.components.count, 3)

          XCTAssertNotNil(self.controller.components[0].collectionView)
          XCTAssertNotNil(self.controller.components[1].collectionView)
          XCTAssertNotNil(self.controller.components[2].tableView)

          XCTAssertEqual(self.controller.components[0].model.items[0].title, "foo1")
          XCTAssertEqual(self.controller.components[0].model.items[1].title, "bar4")

          XCTAssertEqual(self.controller.components[1].model.items[0].title, "foo2")
          XCTAssertEqual(self.controller.components[1].model.items[1].title, "bar2")
          XCTAssertEqual(self.controller.components[1].model.items[2].title, "baz2")
          XCTAssertEqual(self.controller.components[1].model.items[3].title, "baz4")

          XCTAssertEqual(self.controller.components[2].model.items[0].title, "foo3")
          XCTAssertEqual(self.controller.components[2].model.items[1].title, "bar3")
          XCTAssertEqual(self.controller.components[2].model.items[2].title, "baz3")

          XCTAssertEqual(carouselInstance, self.controller.components[0].collectionView)
          XCTAssertNotEqual(gridInstance, self.controller.components[1].collectionView)
          XCTAssertEqual(listInstance, self.controller.components[2].tableView)

          carouselInstance = self.controller.components[0].collectionView
          gridInstance = self.controller.components[1].collectionView
          listInstance = self.controller.components[2].tableView

          self.controller.reloadIfNeeded(updatedModels) {
            XCTAssertEqual(self.controller.components.count, 3)

            XCTAssertNotNil(self.controller.components[0].collectionView)
            XCTAssertNotNil(self.controller.components[1].collectionView)
            XCTAssertNotNil(self.controller.components[2].tableView)

            XCTAssertEqual(self.controller.components[0].model.items[0].title, "foo1")
            XCTAssertEqual(self.controller.components[0].model.items[1].title, "bar4")

            XCTAssertEqual(self.controller.components[1].model.items[0].title, "foo2")
            XCTAssertEqual(self.controller.components[1].model.items[1].title, "bar2")
            XCTAssertEqual(self.controller.components[1].model.items[2].title, "baz2")
            XCTAssertEqual(self.controller.components[1].model.items[3].title, "baz4")

            XCTAssertEqual(self.controller.components[2].model.items[0].title, "foo3")
            XCTAssertEqual(self.controller.components[2].model.items[1].title, "bar3")
            XCTAssertEqual(self.controller.components[2].model.items[2].title, "baz3")

            XCTAssertEqual(carouselInstance, self.controller.components[0].collectionView)
            XCTAssertEqual(gridInstance, self.controller.components[1].collectionView)
            XCTAssertEqual(listInstance, self.controller.components[2].tableView)

            self.controller.reloadIfNeeded(finalUpdate) {

              guard expectation != nil else {
                XCTFail("Exception is nil")
                return
              }

              XCTAssertEqual(self.controller.components.count, 2)

              XCTAssertNotNil(self.controller.components[0].collectionView)
              XCTAssertNotNil(self.controller.components[1].tableView)

              XCTAssertEqual(self.controller.components[0].model.items[0].title, "foo1")
              XCTAssertEqual(self.controller.components[0].model.items[1].title, "bar4")

              XCTAssertEqual(self.controller.components[1].model.items[0].title, "foo3")
              XCTAssertEqual(self.controller.components[1].model.items[1].title, "bar3")
              XCTAssertEqual(self.controller.components[1].model.items[2].title, "baz3")

              XCTAssertEqual(carouselInstance, self.controller.components[0].collectionView)
              XCTAssertNotEqual(listInstance, self.controller.components[1].tableView)

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
      SpotsController.componentsDidReloadComponentModels = nil
    }

    let components = initialComponentModels.map { Component(model: $0) }
    let controller = SpotsController(components: components)

    controller.prepareController()
    controller.reloadIfNeeded(newComponentModels)

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testReloadWithMoreItems() {
    let newItems = [Item(title: "foo"), Item(title: "bar"), Item(title: "baz")]
    var newComponent = controller.components[0].model
    newComponent.items.append(contentsOf: newItems)

    let expectation = self.expectation(description: "Wait for exception to be fulfilled.")
    controller.reloadIfNeeded([newComponent]) {
      let items = [
        Item(title: "foo"),
        Item(title: "bar"),
        Item(title: "baz"),
        Item(title: "foo"),
        Item(title: "bar"),
        Item(title: "baz")
      ]
      XCTAssertTrue(self.controller.components[0].model.items == items)

      newComponent.items = []
      self.controller.reloadIfNeeded([newComponent]) {
        XCTAssertTrue(self.controller.components[0].model.items.isEmpty)

        let items = [
          Item(title: "foo"),
          Item(title: "bar"),
          Item(title: "baz")
        ]
        newComponent.items = items
        self.controller.reloadIfNeeded([newComponent]) {

          let items = [
            Item(title: "foo"),
            Item(title: "bar"),
            Item(title: "baz")
          ]
          XCTAssertTrue(self.controller.components[0].model.items == items)

          expectation.fulfill()
        }
      }
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testReloadIfNeededFilteringEmptyComponentModels() {
    let models = [ComponentModel(), ComponentModel(), ComponentModel()]
    let components = models.map { Component(model: $0) }
    let controller = SpotsController(components: components)

    XCTAssertEqual(controller.components.count, 3)

    let expectation = self.expectation(description: "Wait for exception to be fulfilled.")
    controller.reloadIfNeeded(models) {
      XCTAssertEqual(controller.components.count, 0)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }
}
