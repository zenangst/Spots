@testable import Spots
import XCTest

class UserInterfaceTests: XCTestCase {

  func testEmptyComponent() {
    let model = ComponentModel(kind: .list)
    let component = Component(model: model)
    
    component.setup(with: CGSize(width: 100, height: 100))

    XCTAssertEqual(component.userInterface?.visibleViews.count, 0)
  }

  func testVisibleViewsOnListComponent() {
    Configuration.shared.views.defaultItem = nil
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    let model = ComponentModel(kind: .list, items: items)
    let component = Component(model: model)
    
    component.setup(with: CGSize(width: 200, height: 200))

    XCTAssertEqual(component.userInterface?.visibleViews.count, 3)
  }

  func testVisibleViewsOnGridComponent() {
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    let model = ComponentModel(kind: .grid, items: items)
    let component = Component(model: model)
    
    component.setup(with: CGSize(width: 100, height: 100))

    XCTAssertEqual(component.userInterface?.visibleViews.count, 3)
  }

  func testVisibleViewsOnCarouselComponent() {
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    let layout = Layout(span: 1)
    let model = ComponentModel(kind: .carousel, layout: layout, items: items)
    let component = Component(model: model)
    
    component.setup(with: CGSize(width: 100, height: 100))
    // Expect to only have one visible view as the carousel as a span set to one.
    XCTAssertEqual(component.userInterface?.visibleViews.count, 1)

    component.view.contentOffset.x = 50
    // If we don't call layoutIfNeeded, then `visibleCells` won't update correctly.
    component.collectionView?.layoutIfNeeded()

    // Expect two views to be visible on screen because the x offset is half of a view.
    XCTAssertEqual(component.userInterface?.visibleViews.count, 2)
  }

  func testVisibleIndexesForGridComponent() {
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    let layout = Layout(span: 1)
    let model = ComponentModel(kind: .carousel, layout: layout, items: items)
    let component = Component(model: model)
    component.setup(with: CGSize(width: 100, height: 100))

    XCTAssertEqual(component.userInterface?.visibleIndexes.count, 1)

    component.view.contentOffset.x = 50
    // If we don't call layoutIfNeeded, then `visibleCells` won't update correctly.
    component.collectionView?.layoutIfNeeded()

    #if os(macOS)
      XCTAssertEqual(component.userInterface?.visibleIndexes.count, 3)
    #else
      XCTAssertEqual(component.userInterface?.visibleIndexes.count, 2)
    #endif
  }

  func testVisibleIndexesForListComponent() {
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    let layout = Layout(span: 1)
    let model = ComponentModel(kind: .list, layout: layout, items: items)
    let component = Component(model: model)
    component.setup(with: CGSize(width: 100, height: 100))

    #if os(tvOS)
      XCTAssertEqual(component.userInterface?.visibleIndexes.count, 2)
    #else
      XCTAssertEqual(component.userInterface?.visibleIndexes.count, 3)
    #endif

    component.view.contentOffset.y = 50
    // If we don't call layoutIfNeeded, then `visibleCells` won't update correctly.
    component.tableView?.layoutIfNeeded()

    #if os(macOS)
      XCTAssertEqual(component.userInterface?.visibleIndexes.count, 3)
    #endif

    #if os(tvOS)
      XCTAssertEqual(component.userInterface?.visibleIndexes.count, 3)
    #endif

    #if os(iOS)
      XCTAssertEqual(component.userInterface?.visibleIndexes.count, 2)
    #endif
  }
}
