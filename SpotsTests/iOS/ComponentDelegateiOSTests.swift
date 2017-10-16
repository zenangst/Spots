@testable import Spots
import Foundation
import XCTest

class MockComponentiOSDelegate: ComponentDelegate {
  var countsInvoked = 0

  func component(_ component: Component, itemSelected item: Item) {
    component.model.items[item.index].meta["selected"] = true
    countsInvoked += 1
  }
}

class ComponentDelegateiOSTests: XCTestCase {

  // MARK: - UICollectionView

  func testCollectionViewDelegateSelection() {
    let delegate = MockComponentiOSDelegate()
    let component = Component(model: ComponentModel(kind: .grid, layout: Layout(span: 1), items: [
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
    let component = Component(model: ComponentModel(kind: .grid, layout: Layout(span: 1), items: [Item(title: "title 1")]))

    guard let collectionView = component.collectionView else {
      XCTFail("Unable to resolve collection view.")
      return
    }

    XCTAssertEqual(component.componentDelegate?.collectionView(collectionView, canFocusItemAt: IndexPath(item: 0, section: 0)), true)
    XCTAssertEqual(component.componentDelegate?.collectionView(collectionView, canFocusItemAt: IndexPath(item: 1, section: 0)), false)
  }

  // MARK: - UITableView

  func testTableViewDelegateSelection() {
    let delegate = MockComponentiOSDelegate()
    let component = Component(model: ComponentModel(kind: .list, layout: Layout(span: 1), items: [
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
    Configuration.defaultViewSize = .init(width: 0, height: 44)
    let component = Component(model: ComponentModel(kind: .list, layout: Layout(span: 1), items: [Item(title: "title 1")]))
    component.setup(with: CGSize(width: 100, height: 100))

    guard let tableView = component.tableView else {
      XCTFail("Unable to resolve table view.")
      return
    }

    XCTAssertEqual(component.componentDelegate?.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 0)), 44.0)
    XCTAssertEqual(component.componentDelegate?.tableView(tableView, heightForRowAt: IndexPath(row: 1, section: 0)), 0.0)
  }

  func testTableViewHeaderHeight() {
    Configuration.register(view: RegularView.self, identifier: "regular-header")
    Configuration.register(view: ItemConfigurableView.self, identifier: "item-configurable-header")
    Configuration.register(view: CustomListHeaderView.self, identifier: "custom-header")

    let component = Component(model: ComponentModel(header: Item(kind: "custom-header"), kind: .list))
    component.setup(with: CGSize(width: 100, height: 100))
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
    component.headerView = nil
    tableView.reloadDataSource()

    XCTAssertEqual(delegate.tableView(tableView, heightForHeaderInSection: 0), 0)

    component.model.header = Item(kind: "regular-header")
    component.headerView = nil
    component.setupHeader()
    tableView.reloadDataSource()

    XCTAssertEqual(delegate.tableView(tableView, heightForHeaderInSection: 0), 44)

    component.model.header = Item(kind: "")
    component.headerView = nil
    component.setupHeader()
    tableView.reloadDataSource()

    XCTAssertEqual(delegate.tableView(tableView, heightForHeaderInSection: 0), 0)

    component.model.header = Item(kind: "item-configurable-header")
    component.headerView = nil
    component.setupHeader()
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

    let component = Component(model: ComponentModel(footer: Item(kind: "custom-footer"), kind: .list))
    component.setup(with: CGSize(width: 100, height: 100))
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
    component.footerView = nil
    component.setupFooter()
    tableView.reloadDataSource()

    XCTAssertEqual(delegate.tableView(tableView, heightForFooterInSection: 0), 0)

    component.model.footer = Item(kind: "regular-footer")
    component.footerView = nil
    component.setupFooter()
    tableView.reloadDataSource()

    XCTAssertEqual(delegate.tableView(tableView, heightForFooterInSection: 0), 44)

    component.model.footer = Item(kind: "")
    component.footerView = nil
    component.setupFooter()
    tableView.reloadDataSource()

    XCTAssertEqual(delegate.tableView(tableView, heightForFooterInSection: 0), 0)

    component.model.footer = Item(kind: "item-configurable-footer")
    component.footerView = nil
    component.setupFooter()
    tableView.reloadDataSource()

    XCTAssertEqual(delegate.tableView(tableView, heightForFooterInSection: 0), 75)

    delegate.component = nil
    tableView.reloadDataSource()
    XCTAssertEqual(delegate.tableView(tableView, heightForFooterInSection: 0), 0)
  }
}
