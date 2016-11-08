@testable import Spots
import Brick
import Foundation
import XCTest

class DataSourceTests: XCTestCase {

  func testDataSourceForListableObject() {
    ListSpot.register(view: CustomListCell.self, identifier: "custom")
    let spot = ListSpot(component: Component(items: [
      Item(title: "title 1"),
      Item(title: "title 2")
      ]))

    var itemCell1 = spot.spotDataSource!.tableView(spot.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
    let itemCell2 = spot.spotDataSource!.tableView(spot.tableView, cellForRowAt: IndexPath(row: 1, section: 0))

    XCTAssertNotNil(itemCell1)
    XCTAssertNotNil(itemCell2)
    XCTAssertEqual(itemCell1.textLabel?.text, spot.component.items[0].title)
    XCTAssertEqual(itemCell2.textLabel?.text, spot.component.items[1].title)

    /// Check that data source always returns a cell
    let itemCell3 = spot.spotDataSource!.tableView(spot.tableView, cellForRowAt: IndexPath(row: 2, section: 0))
    XCTAssertNotNil(itemCell3)

    /// Check that preferred view size is applied if height is 0.0
    spot.component.items[0].kind = "custom"
    spot.component.items[0].size.height = 0.0
    itemCell1 = spot.spotDataSource!.tableView(spot.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
    let spotConfigurable = itemCell1 as! CustomListCell
    XCTAssertEqual(spot.component.items[0].size.height, spotConfigurable.preferredViewSize.height)
  }

  func testDataSourceForGridableObject() {
    GridSpot.register(view: CustomGridCell.self, identifier: "custom")
    let spot = GridSpot(component: Component(items: [
      Item(title: "title 1"),
      Item(title: "title 2")
      ]))

    var itemCell1 = spot.spotDataSource!.collectionView(spot.collectionView, cellForItemAt: IndexPath(item: 0, section: 0))
    let itemCell2 = spot.spotDataSource!.collectionView(spot.collectionView, cellForItemAt: IndexPath(item: 1, section: 0))

    XCTAssertNotNil(itemCell1)
    XCTAssertNotNil(itemCell2)

    /// Check that data source always returns a cell
    let itemCell3 = spot.spotDataSource!.collectionView(spot.collectionView, cellForItemAt: IndexPath(item: 2, section: 0))
    XCTAssertNotNil(itemCell3)

    /// Check that preferred view size is applied if height is 0.0
    spot.component.items[0].kind = "custom"
    spot.component.items[0].size.height = 0.0
    itemCell1 = spot.spotDataSource!.collectionView(spot.collectionView, cellForItemAt: IndexPath(item: 0, section: 0))
    let spotConfigurable = itemCell1 as! CustomGridCell
    XCTAssertEqual(spot.component.items[0].size.height, spotConfigurable.preferredViewSize.height)
  }

  func testDataSourceForGridableDefaultHeader() {
    GridSpot.register(defaultHeader: CustomGridHeaderView.self)
    let spot = GridSpot(component: Component(
      header: "",
      items: [
        Item(title: "title 1"),
        Item(title: "title 2")
      ]))
    spot.render().frame.size = CGSize(width: 100, height: 100)
    spot.layout.headerReferenceSize = CGSize(width: 100, height: 48)
    spot.render().layoutSubviews()

    let header = spot.spotDataSource!.collectionView(spot.collectionView, viewForSupplementaryElementOfKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: 0))
    XCTAssertNotNil(header)
    XCTAssert(header is CustomGridHeaderView)
  }

  func testDataSourceForGridableCustomHeader() {
    GridSpot.register(header: CustomGridHeaderView.self, identifier: "custom-header")
    let spot = GridSpot(component: Component(
      header: "custom-header",
      items: [
        Item(title: "title 1"),
        Item(title: "title 2")
      ]))
    spot.render().frame.size = CGSize(width: 100, height: 100)
    spot.layout.headerReferenceSize = CGSize(width: 100, height: 48)
    spot.render().layoutSubviews()

    let header = spot.spotDataSource!.collectionView(spot.collectionView, viewForSupplementaryElementOfKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: 0))
    XCTAssertNotNil(header)
  }
}
