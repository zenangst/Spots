import XCTest
import Spots

class TestSpotsControllerManager: XCTestCase {

  var controller: SpotsController!

  override func setUp() {
    Configuration.registerDefault(view: TestView.self)

    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    let model = ComponentModel(kind: .list, items: items)
    let component = Component(model: model)
    controller = SpotsController(components: [component])
  }

  func testAppendItem() {
    let expectation = self.expectation(description: "Wait for completion")
    controller.append(Item(title: "baz1")) {
      XCTAssertTrue(self.controller.component!.model.items == [
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
      XCTAssertTrue(self.controller.component!.model.items == [
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
      XCTAssertTrue(self.controller.component!.model.items == [
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
      XCTAssertTrue(self.controller.component!.model.items == [
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
      XCTAssertTrue(self.controller.component!.model.items == [
        Item(title: "foo"),
        Item(title: "bar"),
        Item(title: "baz1")
        ])

      self.controller.update(Item(title: "baz1"), index: 2, componentIndex: 0) {
        XCTAssertTrue(self.controller.component!.model.items == [
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

    controller.component!.model.items[0] = Item(title: "foo1")
    controller.component!.model.items[1] = Item(title: "bar1")

    controller.update([0,1], componentIndex: 0) {
      XCTAssertTrue(self.controller.component!.model.items == [
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
      XCTAssertTrue(self.controller.component!.model.items == [
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
      XCTAssertTrue(self.controller.component!.model.items == [
        Item(title: "bar")
        ])

      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testUpdateIfNeeded() {
    let expectation = self.expectation(description: "Wait for completion")
    let items = [
      Item(title: "baz1"),
      Item(title: "baz2")
    ]
    controller.updateIfNeeded(componentAtIndex: 0, items: items) {
      XCTAssertTrue(self.controller.component!.model.items == [
        Item(title: "baz1"),
        Item(title: "baz2")
        ])

      self.controller.updateIfNeeded(componentAtIndex: 0, items: items) {
        XCTAssertTrue(self.controller.component!.model.items == [
          Item(title: "baz1"),
          Item(title: "baz2")
          ])
        expectation.fulfill()
      }
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }
}
