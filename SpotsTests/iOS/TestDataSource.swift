@testable import Spots
import Foundation
import XCTest

class DataSourceTests: XCTestCase {

  override func setUp() {
    Configuration.register(view: CustomGridCell.self, identifier: "custom")
  }

  func testDataSourceForListableObject() {
    Configuration.register(view: CustomListCell.self, identifier: "custom")
    let component = Component(model: ComponentModel(kind: .list, layout: Layout(span: 1.0), items: [
      Item(title: "title 1", kind: "custom"),
      Item(title: "title 2", kind: "custom")
      ]))

    component.setup(with: CGSize(width: 100, height: 100))

    guard let tableView = component.tableView else {
      XCTFail("Unable to resolve table view.")
      return
    }

    var itemCell1: CustomListCell? = component.componentDataSource!.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? CustomListCell
    let itemCell2: CustomListCell? = component.componentDataSource!.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as? CustomListCell

    XCTAssertNotNil(itemCell1)
    XCTAssertNotNil(itemCell2)

    /// Check that data source always returns a cell
    let itemCell3 = component.componentDataSource!.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 0))
    XCTAssertNotNil(itemCell3)

    component.tableView?.reloadData()

    /// Check that preferred view size is applied if height is 0.0
    component.model.items[0].kind = "custom"
    component.model.items[0].size.height = 0.0
    itemCell1 = component.componentDataSource!.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? CustomListCell

    XCTAssertNotNil(itemCell1)
    XCTAssertEqual(component.model.items[0].size.height, 44)
  }

  func testDataSourceForGridableObject() {
    let component = Component(model: ComponentModel(kind: .grid, layout: Layout(span: 1.0), items: [
      Item(title: "title 1", kind: "custom"),
      Item(title: "title 2", kind: "custom")
      ]))

    component.setup(with: CGSize(width: 100, height: 100))

    guard let collectionView = component.collectionView else {
      XCTFail("Unable to resolve collection view.")
      return
    }

    guard let dataSource = component.componentDataSource else {
      XCTFail("Unable to resolve collection view.")
      return
    }


    var itemCell1: CustomGridCell? = dataSource.collectionView(collectionView, cellForItemAt: IndexPath(item: 0, section: 0)) as? CustomGridCell
    let itemCell2: CustomGridCell? = dataSource.collectionView(collectionView, cellForItemAt: IndexPath(item: 1, section: 0)) as? CustomGridCell

    XCTAssertNotNil(itemCell1)
    XCTAssertNotNil(itemCell2)

    /// Check that data source always returns a cell
    let itemCell3 = dataSource.collectionView(collectionView, cellForItemAt: IndexPath(item: 2, section: 0))
    XCTAssertNotNil(itemCell3)

    /// Check that preferred view size is applied if height is 0.0
    component.model.items[0].kind = "custom"
    component.model.items[0].size.height = 0.0
    itemCell1 = dataSource.collectionView(collectionView, cellForItemAt: IndexPath(item: 0, section: 0)) as? CustomGridCell
    XCTAssertNotNil(itemCell1)
    XCTAssertEqual(component.model.items[0].size.height, 44)
  }

  func testDataSourceForGridableCustomHeader() {
    Configuration.register(view: CustomGridHeaderView.self, identifier: "custom-header")
    let component = Component(model: ComponentModel(
      header: Item(kind: "custom-header"),
      kind: .grid,
      layout: Layout(span: 1.0),
      items: [
        Item(title: "title 1"),
        Item(title: "title 2")
      ]))
    component.setup(with: CGSize(width: 100, height: 100))
    component.view.layoutSubviews()

    XCTAssertNotNil(component.headerView)
    XCTAssertEqual(component.headerView?.frame.size, CGSize(width: 100, height: 88))
  }

  func testInfiniteScrollingDataSource() {
    let items = (0...20).map { Item(title: "\($0)", kind: "custom") }
    let model = ComponentModel(kind: .carousel, layout: Layout(infiniteScrolling: true), items: items)
    let component = Component(model: model)
    component.setup(with: .init(width: 100, height: 100))

    guard let collectionView = component.collectionView else {
      XCTFail("Unable to resolve data source")
      return
    }

    guard let dataSource = component.componentDataSource else {
      XCTFail("Unable to resolve data source")
      return
    }

    XCTAssertEqual(dataSource.collectionView(collectionView, numberOfItemsInSection: 0), 22)
  }
}
