@testable import Spots
import Foundation
import XCTest

class DataSourceTests: XCTestCase {

  func testDataSourceForListableObject() {
    Configuration.register(view: CustomListCell.self, identifier: "custom")
    let component = ListComponent(model: ComponentModel(span: 1.0, items: [
      Item(title: "title 1"),
      Item(title: "title 2")
      ]))

    guard let tableView = component.tableView else {
      XCTFail("Unable to resolve table view.")
      return
    }

    var itemCell1 = component.componentDataSource!.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
    let itemCell2 = component.componentDataSource!.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0))

    XCTAssertNotNil(itemCell1)
    XCTAssertNotNil(itemCell2)
    XCTAssertEqual(itemCell1.textLabel?.text, component.model.items[0].title)
    XCTAssertEqual(itemCell2.textLabel?.text, component.model.items[1].title)

    /// Check that data source always returns a cell
    let itemCell3 = component.componentDataSource!.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 0))
    XCTAssertNotNil(itemCell3)

    /// Check that preferred view size is applied if height is 0.0
    component.model.items[0].kind = "custom"
    component.model.items[0].size.height = 0.0
    itemCell1 = component.componentDataSource!.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))

    guard let listWrapper = itemCell1 as? ListWrapper else {
      XCTFail("Unable to resolve list wrapper.")
      return
    }

    guard let itemConfigurable = listWrapper.wrappedView as? CustomListCell else {
      XCTFail("Unable to resolve list wrapper.")
      return
    }

    XCTAssertEqual(component.model.items[0].size.height, itemConfigurable.preferredViewSize.height)
  }

  func testDataSourceForGridableObject() {
    GridComponent.register(view: CustomGridCell.self, identifier: "custom")
    let component = GridComponent(model: ComponentModel(span: 1.0, items: [
      Item(title: "title 1"),
      Item(title: "title 2")
      ]))

    guard let collectionView = component.collectionView else {
      XCTFail("Unable to resolve collection view.")
      return
    }

    var itemCell1 = component.componentDataSource!.collectionView(collectionView, cellForItemAt: IndexPath(item: 0, section: 0))
    let itemCell2 = component.componentDataSource!.collectionView(collectionView, cellForItemAt: IndexPath(item: 1, section: 0))

    XCTAssertNotNil(itemCell1)
    XCTAssertNotNil(itemCell2)

    /// Check that data source always returns a cell
    let itemCell3 = component.componentDataSource!.collectionView(collectionView, cellForItemAt: IndexPath(item: 2, section: 0))
    XCTAssertNotNil(itemCell3)

    /// Check that preferred view size is applied if height is 0.0
    component.model.items[0].kind = "custom"
    component.model.items[0].size.height = 0.0
    itemCell1 = component.componentDataSource!.collectionView(collectionView, cellForItemAt: IndexPath(item: 0, section: 0))
    let itemConfigurable = itemCell1 as! CustomGridCell
    XCTAssertEqual(component.model.items[0].size.height, itemConfigurable.preferredViewSize.height)
  }

//  func testDataSourceForGridableDefaultHeader() {
//    GridComponent.register(defaultHeader: CustomGridHeaderView.self)
//    let component = GridComponent(model: ComponentModel(
//      header: Item(kind: ""),
//      span: 1.0,
//      items: [
//        Item(title: "title 1"),
//        Item(title: "title 2")
//      ]))
//    component.view.frame.size = CGSize(width: 100, height: 100)
//    component.layout.headerReferenceSize = CGSize(width: 100, height: 48)
//    component.view.layoutSubviews()
//
//    let header = component.componentDataSource!.collectionView(component.collectionView, viewForSupplementaryElementOfKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: 0))
//    XCTAssertNotNil(header)
//    XCTAssert(header is CustomGridHeaderView)
//  }
//
//  func testDataSourceForGridableCustomHeader() {
//    GridComponent.register(header: CustomGridHeaderView.self, identifier: "custom-header")
//    let component = GridComponent(model: ComponentModel(
//      header: Item(kind: "custom-header"),
//      span: 1.0,
//      items: [
//        Item(title: "title 1"),
//        Item(title: "title 2")
//      ]))
//    component.view.frame.size = CGSize(width: 100, height: 100)
//    component.layout.headerReferenceSize = CGSize(width: 100, height: 48)
//    component.view.layoutSubviews()
//
//    let header = component.componentDataSource!.collectionView(component.collectionView, viewForSupplementaryElementOfKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: 0))
//    XCTAssertNotNil(header)
//  }
}
