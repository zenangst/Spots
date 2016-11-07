/*
@testable import Spots
import Foundation
import XCTest
import Brick

class SpotableTests : XCTestCase {

  func testAppendingMultipleItemsToSpot() {
    let listSpot = ListSpot(component: Component(title: "Component"))
    listSpot.setup(UIScreen.main.bounds.size)
    var items: [Item] = []

    for i in 0..<10 {
      items.append(Item(title: "Item: \(i)"))
    }

    measure {
      for _ in 0..<5 {
        listSpot.append(items)
        listSpot.render().layoutSubviews()
      }
    }
    XCTAssertEqual(listSpot.items.count, 500)
  }

  func testAppendingMultipleItemsToSpotInController() {
    let controller = Controller(spots: [ListSpot(component: Component(title: "Component"))])
    controller.preloadView()
    controller.viewDidAppear()
    var items: [Item] = []

    for i in 0..<10 {
      items.append(Item(title: "Item: \(i)"))
    }

    measure {
      for _ in 0..<5 {
        controller.append(items, spotIndex: 0, withAnimation: .automatic, completion: nil)
        controller.spots.forEach { $0.render().layoutSubviews() }
      }
    }
    XCTAssertEqual(controller.spots[0].items.count, 500)
  }
}
*/
