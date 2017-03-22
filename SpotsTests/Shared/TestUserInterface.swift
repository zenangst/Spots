@testable import Spots
import XCTest

class TestUserInterface: XCTestCase {

  func testVisibleViewsOnListComponent() {
    let model = ComponentModel(kind: "list")
    let component = Component(model: model)
    
    component.setup(CGSize(width: 100, height: 100))

    /// Expect that the user interface returns zero views because the model has no items.
    XCTAssertEqual(component.userInterface?.visibleViews.count, 0)

    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]

    let expectation = self.expectation(description: "Wait until components has reloaded.")

    component.reloadIfNeeded(items) {
      /// After the component has reloaded with items, three views should be returned.
      XCTAssertEqual(component.userInterface?.visibleViews.count, 3)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testVisibleViewsOnGridComponent() {
    let model = ComponentModel(kind: "grid")
    let component = Component(model: model)
    
    component.setup(CGSize(width: 100, height: 100))

    /// Expect that the user interface returns zero views because the model has no items.
    XCTAssertEqual(component.userInterface?.visibleViews.count, 0)

    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]

    let expectation = self.expectation(description: "Wait until components has reloaded.")

    component.reloadIfNeeded(items) {
      /// After the component has reloaded with items, three views should be returned.
      XCTAssertEqual(component.userInterface?.visibleViews.count, 3)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testVisibleViewsOnCarouselComponent() {
    let layout = Layout(span: 1)
    let model = ComponentModel(kind: "carousel", layout: layout)
    let component = Component(model: model)
    
    component.setup(CGSize(width: 100, height: 100))

    /// Expect that the user interface returns zero views because the model has no items.
    XCTAssertEqual(component.userInterface?.visibleViews.count, 0)

    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]

    let expectation = self.expectation(description: "Wait until components has reloaded.")

    component.reloadIfNeeded(items) {
      /// After the component has loaded, only one of the views should be visisble as span
      /// is set to 1 item per page in the carousel.
      XCTAssertEqual(component.userInterface?.visibleViews.count, 1)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }
}
