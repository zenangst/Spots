@testable import Spots
import Foundation
import XCTest

class TestDelegate: SpotsDelegate {
  var countsInvoked = 0


  func spotable(_ spot: Spotable, itemSelected item: Item) {
    spot.component.items[item.index].meta["selected"] = true
    countsInvoked += 1
  }
}

class DelegateTests: XCTestCase {

  // MARK: - UICollectionView

  func testCollectionViewDelegateSelection() {
    let delegate = TestDelegate()
    let spot = GridSpot(component: Component(span: 1, items: [
      Item(title: "title 1")
      ]))
    spot.delegate = delegate
    spot.spotDelegate?.collectionView(spot.collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
    
    XCTAssertEqual(spot.component.items[0].meta["selected"] as? Bool, true)
    XCTAssertEqual(delegate.countsInvoked, 1)

    spot.spotDelegate?.collectionView(spot.collectionView, didSelectItemAt: IndexPath(item: 1, section: 0))
    XCTAssertEqual(delegate.countsInvoked, 1)
  }

  func testCollectionViewCanFocus() {
    let spot = GridSpot(component: Component(span: 1, items: [Item(title: "title 1")]))
    XCTAssertEqual(spot.spotDelegate?.collectionView(spot.collectionView, canFocusItemAt: IndexPath(item: 0, section: 0)), true)
    XCTAssertEqual(spot.spotDelegate?.collectionView(spot.collectionView, canFocusItemAt: IndexPath(item: 1, section: 0)), false)
  }

  // MARK: - UITableView

  func testTableViewDelegateSelection() {
    let delegate = TestDelegate()
    let spot = ListSpot(component: Component(span: 1, items: [
      Item(title: "title 1")
      ]))
    spot.delegate = delegate
    spot.spotDelegate?.tableView(spot.tableView, didSelectRowAt: IndexPath(item: 0, section: 0))

    XCTAssertEqual(spot.component.items[0].meta["selected"] as? Bool, true)
    XCTAssertEqual(delegate.countsInvoked, 1)

    spot.spotDelegate?.tableView(spot.tableView, didSelectRowAt: IndexPath(item: 1, section: 0))
    XCTAssertEqual(delegate.countsInvoked, 1)
  }

  func testTableViewHeightForRowOnListable() {
    let spot = ListSpot(component: Component(span: 1, items: [Item(title: "title 1")]))
    XCTAssertEqual(spot.spotDelegate?.tableView(spot.tableView, heightForRowAt: IndexPath(row: 0, section: 0)), 44.0)
    XCTAssertEqual(spot.spotDelegate?.tableView(spot.tableView, heightForRowAt: IndexPath(row: 1, section: 0)), 0.0)
  }

  func testDelegateTitleForHeader() {
    ListSpot.register(header: CustomListHeaderView.self, identifier: "list")
    let spot = ListSpot(component: Component(
      title: "title",
      header: "list",
      span: 1,
      items: [
        Item(title: "title 1"),
        Item(title: "title 2")
      ]))
    spot.view.frame.size = CGSize(width: 100, height: 100)
    spot.view.layoutSubviews()

    var view = spot.spotDelegate?.tableView(spot.tableView, viewForHeaderInSection: 0)
    XCTAssert(view is CustomListHeaderView)

    /// Expect to return nil if header is in use.
    var title = spot.spotDelegate?.tableView(spot.tableView, titleForHeaderInSection: 0)
    XCTAssertEqual(title, nil)

    /// Expect to return title if header is empty.
    spot.component.header = ""
    title = spot.spotDelegate?.tableView(spot.tableView, titleForHeaderInSection: 0)
    XCTAssertEqual(title, spot.component.title)

    /// Expect to return nil if title and header is empty.
    spot.component.title = ""
    title = spot.spotDelegate?.tableView(spot.tableView, titleForHeaderInSection: 0)
    XCTAssertEqual(title, nil)

    view = spot.spotDelegate?.tableView(spot.tableView, viewForHeaderInSection: 0)
    XCTAssertEqual(view, nil)


  }
}
