@testable import Spots
import Brick
import Foundation
import XCTest

class TestDelegate: SpotsDelegate {
  var countsInvoked = 0

  func didSelect(item: Item, in spot: Spotable) {
    spot.component.items[item.index].meta["selected"] = true
    countsInvoked += 1
  }
}

class DelegateTests: XCTestCase {

  func testCollectionViewDelegateSelection() {
    let delegate = TestDelegate()
    let spot = GridSpot(component: Component(items: [
      Item(title: "title 1")
      ]))
    spot.delegate = delegate
    spot.spotDelegate.collectionView(spot.collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
    
    XCTAssertEqual(spot.component.items[0].meta["selected"] as? Bool, true)
    XCTAssertEqual(delegate.countsInvoked, 1)

    spot.spotDelegate.collectionView(spot.collectionView, didSelectItemAt: IndexPath(item: 1, section: 0))
    XCTAssertEqual(delegate.countsInvoked, 1)
  }

  func testTableViewDelegateSelection() {
    let delegate = TestDelegate()
    let spot = ListSpot(component: Component(items: [
      Item(title: "title 1")
      ]))
    spot.delegate = delegate
    spot.spotDelegate.tableView(spot.tableView, didSelectRowAt: IndexPath(item: 0, section: 0))

    XCTAssertEqual(spot.component.items[0].meta["selected"] as? Bool, true)
    XCTAssertEqual(delegate.countsInvoked, 1)

    spot.spotDelegate.tableView(spot.tableView, didSelectRowAt: IndexPath(item: 1, section: 0))
    XCTAssertEqual(delegate.countsInvoked, 1)
  }

  func testCollectionViewCanFocus() {
    let spot = GridSpot(component: Component(items: [Item(title: "title 1")]))
    XCTAssertEqual(spot.spotDelegate.collectionView(spot.collectionView, canFocusItemAt: IndexPath(item: 0, section: 0)), true)
    XCTAssertEqual(spot.spotDelegate.collectionView(spot.collectionView, canFocusItemAt: IndexPath(item: 1, section: 0)), false)
  }
}
