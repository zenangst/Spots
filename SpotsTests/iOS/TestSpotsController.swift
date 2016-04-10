@testable import Spots
import Foundation
import XCTest
import Brick

class SpotsControllerTests : XCTestCase {

  func testSpotAtIndex() {
    let component = Component(title: "Component")
    let listSpot = ListSpot(component: component)
    let spotController = SpotsController(spot: listSpot)

    XCTAssertEqual(spotController.spot as? ListSpot, listSpot)
  }

  func testUpdateSpotAtIndex() {
    let component = Component(title: "Component")
    let listSpot = ListSpot(component: component)
    let spotController = SpotsController(spot: listSpot)
    let items = [ViewModel(title: "item1")]

    spotController.update { spot in
      spot.component.items = items
    }

    XCTAssert(spotController.spot.component.items == items)
  }

  func testAppendItem() {
    let component = Component(title: "Component", kind: "list")
    let listSpot = ListSpot(component: component)
    let spotController = SpotsController(spot: listSpot)

    XCTAssert(spotController.spot.component.items.count == 0)

    let item = ViewModel(title: "title1", kind: "list")
    spotController.append(item, spotIndex: 0)

    XCTAssert(spotController.spot.component.items.count == 1)

    if let testItem = spotController.spot.component.items.first {
      XCTAssert(testItem == item)
    }

    // Test appending item without kind
    spotController.append(ViewModel(title: "title2"), spotIndex: 0)

    XCTAssert(spotController.spot.component.items.count == 2)
    XCTAssertEqual(spotController.spot.component.items[1].title, "title2")
  }

  func testAppendItems() {
    let component = Component(title: "Component", kind: "list")
    let listSpot = ListSpot(component: component)
    let spotController = SpotsController(spot: listSpot)

    let items = [
      ViewModel(title: "title1", kind: "list"),
      ViewModel(title: "title2", kind: "list")
    ]
    spotController.append(items, spotIndex: 0)

    XCTAssert(spotController.spot.component.items.count > 0)
    XCTAssert(spotController.spot.component.items == items)

    // Test appending items without kind
    spotController.append([
      ViewModel(title: "title3"),
      ViewModel(title: "title4")
      ], spotIndex: 0)

    XCTAssertEqual(spotController.spot.component.items.count, 4)
    XCTAssertEqual(spotController.spot.component.items[2].title, "title3")
    XCTAssertEqual(spotController.spot.component.items[3].title, "title4")
  }

  func testPrependItems() {
    let component = Component(title: "Component", kind: "list")
    let listSpot = ListSpot(component: component)
    let spotController = SpotsController(spot: listSpot)

    let items = [
      ViewModel(title: "title1", kind: "list"),
      ViewModel(title: "title2", kind: "list")
    ]
    spotController.prepend(items, spotIndex: 0)

    XCTAssertEqual(spotController.spot.component.items.count, 2)
    XCTAssert(spotController.spot.component.items == items)

    spotController.prepend([
      ViewModel(title: "title3"),
      ViewModel(title: "title4")
      ], spotIndex: 0)

    XCTAssertEqual(spotController.spot.component.items[0].title, "title3")
    XCTAssertEqual(spotController.spot.component.items[1].title, "title4")
  }

  func testDeleteItem() {
    let component = Component(title: "Component", kind: "list", items: [
      ViewModel(title: "title1", kind: "list"),
      ViewModel(title: "title2", kind: "list")
      ])
    let initialListSpot = ListSpot(component: component)

    let spotController = SpotsController(spot: initialListSpot)

    let firstItem = spotController.spot.component.items.first

    XCTAssertEqual(firstItem?.title, "title1")
    XCTAssertEqual(firstItem?.index, 0)

    let listSpot = (spotController.spot as! ListSpot)
    listSpot.delete(component.items.first!) {
      let lastItem = spotController.spot.component.items.first

      XCTAssertNotEqual(lastItem?.title, "title1")
      XCTAssertEqual(lastItem?.index, 0)
      XCTAssertEqual(lastItem?.title, "title2")
      XCTAssertEqual(spotController.spot.component.items.count, 1)
    }
  }

  func testComputedPropertiesOnSpotable() {
    let component = Component(title: "Component", kind: "list", items: [
      ViewModel(title: "title1", kind: "list"),
      ViewModel(title: "title2", kind: "list")
      ])
    let spot = ListSpot(component: component)

    XCTAssert(spot.items == component.items)

    let newItems = [ViewModel(title: "title3", kind: "list")]
    spot.items = newItems
    XCTAssertFalse(spot.items == component.items)
    XCTAssert(spot.items == newItems)
  }

  func testFindAndFilterSpotWithClosure() {
    let listSpot = ListSpot(component: Component(title: "ListSpot"))
    let listSpot2 = ListSpot(component: Component(title: "ListSpot2"))
    let gridSpot = GridSpot(component: Component(title: "GridSpot", items: [ViewModel(title: "ViewModel")]))
    let spotController = SpotsController(spots: [listSpot, listSpot2, gridSpot])

    XCTAssertNotNil(spotController.spot{ $1.component.title == "ListSpot" })
    XCTAssertNotNil(spotController.spot{ $1.component.title == "GridSpot" })
    XCTAssertNotNil(spotController.spot{ $1 is Listable })
    XCTAssertNotNil(spotController.spot{ $1 is Gridable })
    XCTAssertNotNil(spotController.spot{ $1.items.filter{ $0.title == "ViewModel" }.first != nil })
    XCTAssertEqual(spotController.spot{ $0.index == 0 }?.component.title, "ListSpot")
    XCTAssertEqual(spotController.spot{ $0.index == 1 }?.component.title, "ListSpot2")
    XCTAssertEqual(spotController.spot{ $0.index == 2 }?.component.title, "GridSpot")

    XCTAssert(spotController.filter { $0 is Listable }.count == 2)
  }

  func testJSONInitialiser() {
    let sourceController = SpotsController(spot: ListSpot().then {
      $0.items = [ViewModel(title: "First item")]
      })
    let jsonController = SpotsController([
      "components" : [
        ["type" : "list",
          "items" : [
            ["title" : "First item"]
          ]
        ]
      ]
      ])

    XCTAssert(sourceController.spot.component == jsonController.spot.component)
  }
}
