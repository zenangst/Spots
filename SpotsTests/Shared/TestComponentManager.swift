import XCTest
@testable import Spots

class TestComponentEngine: XCTestCase {

  var component: Component!

  override func setUp() {
    Configuration.registerDefault(view: TestView.self)

    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    let model = ComponentModel(kind: .list, items: items)
    component = Component(model: model)
    component.setup(with: .init(width: 1000, height: 1000))
  }

  func testAppendItem() {
    let expectation = self.expectation(description: "Wait for completion")
    component.manager.append(item: Item(title: "foo"), component: component) { 
      XCTAssertTrue(self.component.model.items.first! == Item(title: "foo"))
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendItemWithEmptyModel() {
    component = Component(model: ComponentModel(kind: .list))
    let expectation = self.expectation(description: "Wait for completion")
    component.manager.append(item: Item(title: "foo"), component: component) {
      XCTAssertTrue(self.component.model.items.first! == Item(title: "foo"))
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendItems() {
    let expectation = self.expectation(description: "Wait for completion")
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    component.manager.append(items: items, component: component) {
      XCTAssertTrue(self.component.model.items == [
        Item(title: "foo"),
        Item(title: "bar"),
        Item(title: "baz"),
        Item(title: "foo"),
        Item(title: "bar"),
        Item(title: "baz")
        ])
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendItemsWithEmptyModel() {
    component = Component(model: ComponentModel(kind: .list))
    let expectation = self.expectation(description: "Wait for completion")
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    component.manager.append(items: items, component: component) {
      XCTAssertTrue(self.component.model.items == [
        Item(title: "foo"),
        Item(title: "bar"),
        Item(title: "baz")
        ])
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testPrependItems() {
    let expectation = self.expectation(description: "Wait for completion")
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    component.manager.prepend(items: items, component: component) {
      XCTAssertTrue(self.component.model.items == [
        Item(title: "foo"),
        Item(title: "bar"),
        Item(title: "baz"),
        Item(title: "foo"),
        Item(title: "bar"),
        Item(title: "baz")
        ])
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testPrependItemsWithExistingItems() {
    let model = ComponentModel(kind: .list, items: [Item(title: "f00")])
    let component = Component(model: model)
    component.setup(with: CGSize(width: 100, height: 100))
    let expectation = self.expectation(description: "Wait for completion")
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    component.manager.prepend(items: items, component: component) {
      XCTAssertTrue(component.model.items == [
        Item(title: "foo"),
        Item(title: "bar"),
        Item(title: "baz"),
        Item(title: "f00")
        ])
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testInsertItem() {
    let expectation = self.expectation(description: "Wait for completion")
    component.manager.insert(item: Item(title: "bar"), atIndex: 1, component: component) {
      XCTAssertTrue(self.component.model.items == [
        Item(title: "foo"),
        Item(title: "bar"),
        Item(title: "bar"),
        Item(title: "baz")
        ])
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testInsertWithEmptyModel() {
    let model = ComponentModel(kind: .list)
    let component = Component(model: model)
    let expectation = self.expectation(description: "Wait for completion")
    component.manager.insert(item: Item(title: "foo"), atIndex: 0, component: component) {
      XCTAssertTrue(component.model.items == [
        Item(title: "foo"),
        ]
      )
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testDeleteItem() {
    let expectation = self.expectation(description: "Wait for completion")
    component.manager.delete(item: Item(title: "foo"), component: component) {
      XCTAssertTrue(self.component.model.items == [
        Item(title: "bar"),
        Item(title: "baz")
        ])

      // Check that trying to delete a non-existing item has no affect on the
      // data structure.
      self.component.manager.delete(item: Item(title: "foo"), component: self.component) {
        XCTAssertTrue(self.component.model.items == [
          Item(title: "bar"),
          Item(title: "baz")
          ])
        expectation.fulfill()
      }
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testDeleteItems() {
    let expectation = self.expectation(description: "Wait for completion")
    component.manager.delete(items: [Item(title: "foo"), Item(title: "bar")], component: component) {
      XCTAssertTrue(self.component.model.items == [
        Item(title: "baz")
        ])
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testDeleteItemAtIndex() {
    let expectation = self.expectation(description: "Wait for completion")
    component.manager.delete(atIndex: 1, component: component) {
      XCTAssertTrue(self.component.model.items == [
        Item(title: "foo"),
        Item(title: "baz")
        ])
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testDeleteItemsAtIndex() {
    let expectation = self.expectation(description: "Wait for completion")
    component.manager.delete(atIndexes: [0,2], component: component) {
      XCTAssertTrue(self.component.model.items == [
        Item(title: "bar")
        ])
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testUpdateItem() {
    let expectation = self.expectation(description: "Wait for completion")
    component.manager.update(item: Item(title: "bar"), atIndex: 0, component: component) {
      XCTAssertTrue(self.component.model.items.first! == Item(title: "bar"))
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testReloadIndexes() {
    var view: TestView?
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]

    component = Component(model: ComponentModel(kind: .list, items: items))
    component.setup(with: .init(width: 1000, height: 1000))

    view = component.ui(at: 0)

    XCTAssertTrue(view!.item! == Item(title: "foo"))

    component.model.items = [
      Item(title: "foo1"),
      Item(title: "bar1"),
      Item(title: "baz1")
    ]

    let expectation = self.expectation(description: "Wait for completion")
    component.manager.reload(indexes: [0], component: component) {

      // Test that only the first item was reloaded.
      view = self.component.ui(at: 0)
      XCTAssertTrue(view!.item! == Item(title: "foo1"))
      view = self.component.ui(at: 1)
      XCTAssertTrue(view!.item! == Item(title: "bar"))
      view = self.component.ui(at: 2)
      XCTAssertTrue(view!.item! == Item(title: "baz"))

      self.component.manager.reload(indexes: nil, component: self.component) {
        view = self.component.ui(at: 0)
        XCTAssertTrue(view!.item! == Item(title: "foo1"))
        view = self.component.ui(at: 1)
        XCTAssertTrue(view!.item! == Item(title: "bar1"))
        view = self.component.ui(at: 2)
        XCTAssertTrue(view!.item! == Item(title: "baz1"))

        self.component.model.items = [
          Item(title: "foo2"),
          Item(title: "bar2"),
          Item(title: "baz2")
        ]

        // Check that reloading without animations render the same kind of results as
        // with animations.
        self.component.manager.reload(indexes: nil, component: self.component, withAnimation: .none, completion: { 
          view = self.component.ui(at: 0)
          XCTAssertTrue(view!.item! == Item(title: "foo2"))
          view = self.component.ui(at: 1)
          XCTAssertTrue(view!.item! == Item(title: "bar2"))
          view = self.component.ui(at: 2)
          XCTAssertTrue(view!.item! == Item(title: "baz2"))

          expectation.fulfill()
        })
      }
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testReloadIfNeededWithChanges() {
    var view: TestView?

    var childItem = Item(title: "baz")
    childItem.children.append(ComponentModel(kind: .carousel).dictionary)

    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      childItem
    ]

    component = Component(model: ComponentModel(kind: .list, items: items))
    component.setup(with: .init(width: 1000, height: 1000))

    let newItems = [
      Item(title: "foo1"),
      Item(title: "bar"),
      Item(title: "update"),
      Item(title: "new with child")
    ]

    guard let changes = DiffManager().compare(oldItems: component.model.items, newItems: newItems) else {
      XCTFail("Unable to resolve diff")
      return
    }

    XCTAssertEqual(changes.insertions, [3])
    XCTAssertEqual(changes.updates, [0])
    XCTAssertEqual(changes.reloads, [1])
    XCTAssertEqual(changes.deletions, [])
    XCTAssertEqual(changes.childUpdates, [2])

    let expectation = self.expectation(description: "Wait for completion")
    component.manager.reloadIfNeeded(with: changes, component: component, updateDataSource: {
      self.component.model.items = newItems
    }) { 
      view = self.component.ui(at: 0)
      XCTAssertTrue(view!.item! == Item(title: "foo1"))
      view = self.component.ui(at: 1)
      XCTAssertTrue(view!.item! == Item(title: "bar"))
      view = self.component.ui(at: 2)
      XCTAssertTrue(view!.item! == Item(title: "update"))
      view = self.component.ui(at: 3)
      XCTAssertTrue(view!.item! == Item(title: "new with child"))

      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testReloadIfNeededWithItems() {
    var view: TestView?

    let items = [
      Item(title: "foo1"),
      Item(title: "bar1"),
      Item(title: "baz1")
    ]

    view = self.component.ui(at: 0)
    XCTAssertTrue(view!.item! == Item(title: "foo"))
    view = self.component.ui(at: 1)
    XCTAssertTrue(view!.item! == Item(title: "bar"))
    view = self.component.ui(at: 2)
    XCTAssertTrue(view!.item! == Item(title: "baz"))

    let expectation = self.expectation(description: "Wait for completion")

    component.manager.reloadIfNeeded(items: items, component: component) {
      view = self.component.ui(at: 0)
      XCTAssertTrue(view!.item! == Item(title: "foo1"))
      view = self.component.ui(at: 1)
      XCTAssertTrue(view!.item! == Item(title: "bar1"))
      view = self.component.ui(at: 2)
      XCTAssertTrue(view!.item! == Item(title: "baz1"))

      // Check that reloading with the same items has no effect.
      self.component.manager.reloadIfNeeded(items: items, component: self.component) {
        view = self.component.ui(at: 0)
        XCTAssertTrue(view!.item! == Item(title: "foo1"))
        view = self.component.ui(at: 1)
        XCTAssertTrue(view!.item! == Item(title: "bar1"))
        view = self.component.ui(at: 2)
        XCTAssertTrue(view!.item! == Item(title: "baz1"))
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testReloadIfNeededWithJSON() {
    let json: [String : Any] = [
      "kind" : "list",
      "items" : [
        ["title" : "foo1"],
        ["title" : "bar1"],
        ["title" : "baz1"]
      ]
    ]

    var view: TestView?

    view = self.component.ui(at: 0)
    XCTAssertTrue(view!.item! == Item(title: "foo"))
    view = self.component.ui(at: 1)
    XCTAssertTrue(view!.item! == Item(title: "bar"))
    view = self.component.ui(at: 2)
    XCTAssertTrue(view!.item! == Item(title: "baz"))

    let expectation = self.expectation(description: "Wait for completion")
    component.manager.reloadIfNeeded(json: json, component: component, withAnimation: .automatic) {
      view = self.component.ui(at: 0)
      XCTAssertTrue(view!.item! == Item(title: "foo1"))
      view = self.component.ui(at: 1)
      XCTAssertTrue(view!.item! == Item(title: "bar1"))
      view = self.component.ui(at: 2)
      XCTAssertTrue(view!.item! == Item(title: "baz1"))

      self.component.manager.reloadIfNeeded(json: json, component: self.component, withAnimation: .automatic) {
        view = self.component.ui(at: 0)
        XCTAssertTrue(view!.item! == Item(title: "foo1"))
        view = self.component.ui(at: 1)
        XCTAssertTrue(view!.item! == Item(title: "bar1"))
        view = self.component.ui(at: 2)
        XCTAssertTrue(view!.item! == Item(title: "baz1"))

        expectation.fulfill()
      }
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }
}
