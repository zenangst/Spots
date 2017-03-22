@testable import Spots
import XCTest

class TestUserInterface: XCTestCase {

  func testEmptyComponent() {
    let model = ComponentModel(kind: "list")
    let component = Component(model: model)
    
    component.setup(CGSize(width: 100, height: 100))

    XCTAssertEqual(component.userInterface?.visibleViews.count, 0)
  }

  func testVisibleViewsOnListComponent() {
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    let model = ComponentModel(kind: "list", items: items)
    let component = Component(model: model)
    
    component.setup(CGSize(width: 100, height: 100))

    XCTAssertEqual(component.userInterface?.visibleViews.count, 3)
  }

  func testVisibleViewsOnGridComponent() {
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    let model = ComponentModel(kind: "grid", items: items)
    let component = Component(model: model)
    
    component.setup(CGSize(width: 100, height: 100))

    XCTAssertEqual(component.userInterface?.visibleViews.count, 3)
  }

  func testVisibleViewsOnCarouselComponent() {
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    let layout = Layout(span: 1)
    let model = ComponentModel(kind: "carousel", layout: layout, items: items)
    let component = Component(model: model)
    
    component.setup(CGSize(width: 100, height: 100))

    /// Expect to only have one visible view as the carousel as a span set to one.
    XCTAssertEqual(component.userInterface?.visibleViews.count, 1)
  }
}
