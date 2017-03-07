@testable import Spots
import Foundation
import XCTest

class TestDelegate: ComponentDelegate {
  var countsInvoked = 0

  func component(_ component: CoreComponent, itemSelected item: Item) {
    component.model.items[item.index].meta["selected"] = true
    countsInvoked += 1
  }
}

class DelegateTests: XCTestCase {

  // MARK: - UICollectionView

  func testCollectionViewDelegateSelection() {
    let delegate = TestDelegate()
    let component = GridComponent(model: ComponentModel(span: 1, items: [
      Item(title: "title 1")
      ]))
    component.delegate = delegate
    component.spotDelegate?.collectionView(component.collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))

    XCTAssertEqual(component.model.items[0].meta["selected"] as? Bool, true)
    XCTAssertEqual(delegate.countsInvoked, 1)

    component.spotDelegate?.collectionView(component.collectionView, didSelectItemAt: IndexPath(item: 1, section: 0))
    XCTAssertEqual(delegate.countsInvoked, 1)
  }

  func testCollectionViewCanFocus() {
    let component = GridComponent(model: ComponentModel(span: 1, items: [Item(title: "title 1")]))
    XCTAssertEqual(component.spotDelegate?.collectionView(component.collectionView, canFocusItemAt: IndexPath(item: 0, section: 0)), true)
    XCTAssertEqual(component.spotDelegate?.collectionView(component.collectionView, canFocusItemAt: IndexPath(item: 1, section: 0)), false)
  }

  // MARK: - UITableView

  func testTableViewDelegateSelection() {
    let delegate = TestDelegate()
    let component = ListComponent(model: ComponentModel(span: 1, items: [
      Item(title: "title 1")
      ]))
    component.delegate = delegate
    component.spotDelegate?.tableView(component.tableView, didSelectRowAt: IndexPath(item: 0, section: 0))

    XCTAssertEqual(component.model.items[0].meta["selected"] as? Bool, true)
    XCTAssertEqual(delegate.countsInvoked, 1)

    component.spotDelegate?.tableView(component.tableView, didSelectRowAt: IndexPath(item: 1, section: 0))
    XCTAssertEqual(delegate.countsInvoked, 1)
  }

  func testTableViewHeightForRowOnListable() {
    let component = ListComponent(model: ComponentModel(span: 1, items: [Item(title: "title 1")]))
    component.setup(CGSize(width: 100, height: 100))
    XCTAssertEqual(component.spotDelegate?.tableView(component.tableView, heightForRowAt: IndexPath(row: 0, section: 0)), 44.0)
    XCTAssertEqual(component.spotDelegate?.tableView(component.tableView, heightForRowAt: IndexPath(row: 1, section: 0)), 0.0)
  }

  func testDelegateTitleForHeader() {
    ListComponent.register(header: CustomListHeaderView.self, identifier: "list")
    let component = ListComponent(model: ComponentModel(
      title: "title",
      header: "list",
      span: 1,
      items: [
        Item(title: "title 1"),
        Item(title: "title 2")
      ]))
    component.view.frame.size = CGSize(width: 100, height: 100)
    component.view.layoutSubviews()

    var view = component.spotDelegate?.tableView(component.tableView, viewForHeaderInSection: 0)
    XCTAssert(view is CustomListHeaderView)

    /// Expect to return nil if header is in use.
    var title = component.spotDelegate?.tableView(component.tableView, titleForHeaderInSection: 0)
    XCTAssertEqual(title, nil)

    /// Expect to return title if header is empty.
    component.model.header = ""
    title = component.spotDelegate?.tableView(component.tableView, titleForHeaderInSection: 0)
    XCTAssertEqual(title, component.model.title)

    /// Expect to return nil if title and header is empty.
    component.model.title = ""
    title = component.spotDelegate?.tableView(component.tableView, titleForHeaderInSection: 0)
    XCTAssertEqual(title, nil)

    view = component.spotDelegate?.tableView(component.tableView, viewForHeaderInSection: 0)
    XCTAssertEqual(view, nil)

  }
}
