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

    guard let collectionView = component.collectionView else {
      XCTFail("Unable to resolve collection view.")
      return
    }

    component.componentDelegate?.collectionView(collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))

    XCTAssertEqual(component.model.items[0].meta["selected"] as? Bool, true)
    XCTAssertEqual(delegate.countsInvoked, 1)

    component.componentDelegate?.collectionView(collectionView, didSelectItemAt: IndexPath(item: 1, section: 0))
    XCTAssertEqual(delegate.countsInvoked, 1)
  }

  func testCollectionViewCanFocus() {
    let component = GridComponent(model: ComponentModel(span: 1, items: [Item(title: "title 1")]))

    guard let collectionView = component.collectionView else {
      XCTFail("Unable to resolve collection view.")
      return
    }

    XCTAssertEqual(component.componentDelegate?.collectionView(collectionView, canFocusItemAt: IndexPath(item: 0, section: 0)), true)
    XCTAssertEqual(component.componentDelegate?.collectionView(collectionView, canFocusItemAt: IndexPath(item: 1, section: 0)), false)
  }

  // MARK: - UITableView

  func testTableViewDelegateSelection() {
    let delegate = TestDelegate()
    let component = ListComponent(model: ComponentModel(span: 1, items: [
      Item(title: "title 1")
      ]))
    component.delegate = delegate

    guard let tableView = component.tableView else {
      XCTFail("Unable to resolve table view.")
      return
    }

    component.componentDelegate?.tableView(tableView, didSelectRowAt: IndexPath(item: 0, section: 0))

    XCTAssertEqual(component.model.items[0].meta["selected"] as? Bool, true)
    XCTAssertEqual(delegate.countsInvoked, 1)

    component.componentDelegate?.tableView(tableView, didSelectRowAt: IndexPath(item: 1, section: 0))
    XCTAssertEqual(delegate.countsInvoked, 1)
  }

  func testTableViewHeightForRowOnListable() {
    let component = ListComponent(model: ComponentModel(span: 1, items: [Item(title: "title 1")]))
    component.setup(CGSize(width: 100, height: 100))

    guard let tableView = component.tableView else {
      XCTFail("Unable to resolve table view.")
      return
    }

    XCTAssertEqual(component.componentDelegate?.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 0)), 44.0)
    XCTAssertEqual(component.componentDelegate?.tableView(tableView, heightForRowAt: IndexPath(row: 1, section: 0)), 0.0)
  }

  func testDelegateTitleForHeader() {
//    ListComponent.register(header: CustomListHeaderView.self, identifier: "list")
    let component = ListComponent(model: ComponentModel(
      title: "title",
      header: Item(kind: "list"),
      span: 1,
      items: [
        Item(title: "title 1"),
        Item(title: "title 2")
      ]))
    component.view.frame.size = CGSize(width: 100, height: 100)
    component.view.layoutSubviews()

    guard let tableView = component.tableView else {
      XCTFail("Unable to resolve table view.")
      return
    }

    var view = component.componentDelegate?.tableView(tableView, viewForHeaderInSection: 0)
    XCTAssert(view is CustomListHeaderView)

    /// Expect to return nil if header is in use.
    var title = component.componentDelegate?.tableView(tableView, titleForHeaderInSection: 0)
    XCTAssertEqual(title, nil)

    /// Expect to return title if header is empty.
    component.model.header = nil
    title = component.componentDelegate?.tableView(tableView, titleForHeaderInSection: 0)
    XCTAssertEqual(title, component.model.title)

    /// Expect to return nil if title and header is empty.
    component.model.title = ""
    title = component.componentDelegate?.tableView(tableView, titleForHeaderInSection: 0)
    XCTAssertEqual(title, nil)

    view = component.componentDelegate?.tableView(tableView, viewForHeaderInSection: 0)
    XCTAssertEqual(view, nil)
  }

  func testTableViewHeaderHeight() {
    Configuration.register(view: RegularView.self, identifier: "regular-header")
    Configuration.register(view: ItemConfigurableView.self, identifier: "item-configurable-header")
    Configuration.register(view: CustomListHeaderView.self, identifier: "custom-header")

    let component = Component(model: ComponentModel(header: Item(kind: "custom-header")))
    component.setup(CGSize(width: 100, height: 100))
    component.view.layoutSubviews()

    guard let tableView = component.tableView else {
      XCTFail("Unable to resolve table view.")
      return
    }

    guard let delegate = component.componentDelegate else {
      XCTFail("Unable to resolve delegate.")
      return
    }

    XCTAssertEqual(delegate.tableView(tableView, heightForHeaderInSection: 0), 88)

    component.model.header = nil
    tableView.reloadDataSource()

    XCTAssertEqual(delegate.tableView(tableView, heightForHeaderInSection: 0), 0)

    component.model.header = Item(kind: "regular-header")
    tableView.reloadDataSource()

    XCTAssertEqual(delegate.tableView(tableView, heightForHeaderInSection: 0), 44)

    component.model.header = Item(kind: "")
    tableView.reloadDataSource()

    XCTAssertEqual(delegate.tableView(tableView, heightForHeaderInSection: 0), 0)

    component.model.header = Item(kind: "item-configurable-header")
    tableView.reloadDataSource()

    XCTAssertEqual(delegate.tableView(tableView, heightForHeaderInSection: 0), 75)

    delegate.component = nil
    tableView.reloadDataSource()
    XCTAssertEqual(delegate.tableView(tableView, heightForFooterInSection: 0), 0)
  }

  func testTableViewFooterHeight() {
    Configuration.register(view: RegularView.self, identifier: "regular-footer")
    Configuration.register(view: ItemConfigurableView.self, identifier: "item-configurable-footer")
    Configuration.register(view: CustomListHeaderView.self, identifier: "custom-footer")

    let component = Component(model: ComponentModel(footer: Item(kind: "custom-footer")))
    component.setup(CGSize(width: 100, height: 100))
    component.view.layoutSubviews()

    guard let tableView = component.tableView else {
      XCTFail("Unable to resolve table view.")
      return
    }

    guard let delegate = component.componentDelegate else {
      XCTFail("Unable to resolve delegate.")
      return
    }

    XCTAssertEqual(delegate.tableView(tableView, heightForFooterInSection: 0), 88)

    component.model.footer = nil
    tableView.reloadDataSource()

    XCTAssertEqual(delegate.tableView(tableView, heightForFooterInSection: 0), 0)

    component.model.footer = Item(kind: "regular-footer")
    tableView.reloadDataSource()

    XCTAssertEqual(delegate.tableView(tableView, heightForFooterInSection: 0), 44)

    component.model.footer = Item(kind: "")
    tableView.reloadDataSource()

    XCTAssertEqual(delegate.tableView(tableView, heightForFooterInSection: 0), 0)

    component.model.header = Item(kind: "item-configurable-footer")
    tableView.reloadDataSource()

    XCTAssertEqual(delegate.tableView(tableView, heightForHeaderInSection: 0), 75)

    delegate.component = nil
    tableView.reloadDataSource()
    XCTAssertEqual(delegate.tableView(tableView, heightForFooterInSection: 0), 0)
  }
}
