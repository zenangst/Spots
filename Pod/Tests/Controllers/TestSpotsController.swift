import Foundation
import XCTest

class SpotsControllerTests : XCTestCase {

  var spotController: SpotsController?

  func testSpotAtIndex() {
    let component = Component(title: "Component")
    let listSpot = ListSpot(component: component)
    spotController = SpotsController(spots: [listSpot], refreshable: true)

    XCTAssertEqual(spotController?.spotAtIndex(0) as? ListSpot, listSpot)
  }
  
  func testUpdateSpotAtIndex() {
    let component = Component(title: "Component")
    let listSpot = ListSpot(component: component)
    spotController = SpotsController(spots: [listSpot], refreshable: true)

    let items = [ListItem(title: "item1")]
    spotController?.updateSpotAtIndex(0, closure: { spot -> Spotable in
      spot.component.items = items
      return spot
    })

    if let componentItems = spotController?.spotAtIndex(0)?.component.items {
      XCTAssert(componentItems == items)
    }
  }

  func testAppendItem() {
    let component = Component(title: "Component", kind: "list")
    let listSpot = ListSpot(component: component)
    spotController = SpotsController(spots: [listSpot], refreshable: true)

    XCTAssert(spotController?.spotAtIndex(0)?.component.items.count == 0)

    let item = ListItem(title: "title1", kind: "list")
    spotController?.append(item, spotIndex: 0)

    XCTAssert(spotController?.spotAtIndex(0)?.component.items.count == 1)

    if let testItem = spotController?.spotAtIndex(0)?.component.items.first {
      XCTAssert(testItem == item)
    }

    // Test appending item without kind
    spotController?.append(ListItem(title: "title2"), spotIndex: 0)

    XCTAssert(spotController?.spotAtIndex(0)?.component.items.count == 2)

    if let testItem = spotController?.spotAtIndex(0)?.component.items[1] {
      XCTAssertEqual(testItem.kind, component.kind)
    }
  }

  func testAppendItems() {
    let component = Component(title: "Component", kind: "list")
    let listSpot = ListSpot(component: component)
    spotController = SpotsController(spots: [listSpot], refreshable: true)

    let items = [
      ListItem(title: "title1", kind: "list"),
      ListItem(title: "title2", kind: "list")
    ]
    spotController?.append(items, spotIndex: 0)

    XCTAssert(spotController?.spotAtIndex(0)?.component.items.count > 0)

    if let testItems = spotController?.spotAtIndex(0)?.component.items {
      XCTAssert(testItems == items)
    }

    // Test appending items without kind
    spotController?.append([
      ListItem(title: "title3"),
      ListItem(title: "title4")
      ], spotIndex: 0)

    XCTAssert(spotController?.spotAtIndex(0)?.component.items.count == 4)
    XCTAssertEqual(spotController?.spotAtIndex(0)?.component.items[2].kind, component.kind)
    XCTAssertEqual(spotController?.spotAtIndex(0)?.component.items[3].kind, component.kind)
  }

  func testPrependItems() {
    let component = Component(title: "Component", kind: "list")
    let listSpot = ListSpot(component: component)
    spotController = SpotsController(spots: [listSpot], refreshable: true)

    let items = [
      ListItem(title: "title1", kind: "list"),
      ListItem(title: "title2", kind: "list")
    ]
    spotController?.prepend(items, spotIndex: 0)

    XCTAssert(spotController?.spotAtIndex(0)?.component.items.count == 2)

    if let testItems = spotController?.spotAtIndex(0)?.component.items {
      XCTAssert(testItems == items)
    }

    spotController?.prepend([
      ListItem(title: "title3"),
      ListItem(title: "title4")
      ], spotIndex: 0)

    XCTAssertEqual(spotController?.spotAtIndex(0)?.component.items[0].kind, component.kind)
    XCTAssertEqual(spotController?.spotAtIndex(0)?.component.items[1].kind, component.kind)
  }

  func testDeleteItem() {
    let component = Component(title: "Component", kind: "list", items: [
      ListItem(title: "title1", kind: "list"),
      ListItem(title: "title2", kind: "list")
      ])
    let initialListSpot = ListSpot(component: component)

    spotController = SpotsController(spots: [initialListSpot], refreshable: true)

    let firstItem = spotController?.spotAtIndex(0)?.component.items.first

    XCTAssertEqual(firstItem?.title, "title1")
    XCTAssertEqual(firstItem?.index, 0)

    let listSpot = (spotController?.spotAtIndex(0) as! ListSpot)
    listSpot.delete(component.items.first!) {
      let lastItem = self.spotController?.spotAtIndex(0)?.component.items.first

      XCTAssert(self.spotController?.spotAtIndex(0)?.component.items.count == 1)
      XCTAssertNotEqual(lastItem?.title, "title1")
      XCTAssertEqual(lastItem?.title, "title2")
      XCTAssertEqual(lastItem?.index, 0)
    }
  }
}
