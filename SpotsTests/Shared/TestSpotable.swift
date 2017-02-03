@testable import Spots
import Foundation
import XCTest
import Brick

class SpotableTests : XCTestCase {

  func testAppendingMultipleItemsToSpot() {
    let listSpot = ListSpot(component: Component(title: "Component", span: 1.0))
    listSpot.setup(CGSize(width: 100, height: 100))
    var items: [Item] = []

    for i in 0..<10 {
      items.append(Item(title: "Item: \(i)"))
    }

    measure {
      for _ in 0..<5 {
        listSpot.append(items)
        listSpot.view.layoutSubviews()
      }
    }

    let exception = self.expectation(description: "Wait until done")
    Dispatch.after(seconds: 1.0) {
      XCTAssertEqual(listSpot.items.count, 500)
      exception.fulfill()
    }
    waitForExpectations(timeout: 1.5, handler: nil)
  }

  func testAppendingMultipleItemsToSpotInController() {
    let controller = Controller(spots: [ListSpot(component: Component(title: "Component", span: 1.0))])
    controller.prepareController()
    var items: [Item] = []

    for i in 0..<10 {
      items.append(Item(title: "Item: \(i)"))
    }

    measure {
      for _ in 0..<5 {
        controller.append(items, spotIndex: 0, withAnimation: .automatic, completion: nil)
        controller.spots.forEach { $0.view.layoutSubviews() }
      }
    }

    let exception = self.expectation(description: "Wait until done")
    Dispatch.after(seconds: 1.0) {
      XCTAssertEqual(controller.spots[0].items.count, 500)
      exception.fulfill()
    }
    waitForExpectations(timeout: 1.5, handler: nil)
  }

  func testResolvingUIFromGridableSpot() {
    let kind = "test-view"

    Configuration.register(view: TestView.self, identifier: kind)

    let parentSize = CGSize(width: 100, height: 100)
    let component = Component(items: [Item(title: "foo", kind: kind)])
    let spot = GridSpot(component: component)
    spot.view.frame.size = parentSize
    spot.setup(parentSize)
    spot.layout(parentSize)
    spot.view.layoutIfNeeded()

    guard let genericView: View = spot.ui(at: 0) else {
      XCTFail()
      return
    }

    XCTAssertFalse(type(of: genericView) === GridWrapper.self)
    XCTAssertTrue(type(of: genericView) === TestView.self)
  }

  func testResolvingUIFromListableSpot() {
    let kind = "test-view"

    Configuration.register(view: TestView.self, identifier: kind)

    let parentSize = CGSize(width: 100, height: 100)
    let component = Component(items: [Item(title: "foo", kind: kind)])
    let spot = ListSpot(component: component)

    spot.setup(parentSize)
    spot.layout(parentSize)
    spot.view.layoutSubviews()

    guard let genericView: View = spot.ui(at: 0) else {
      XCTFail()
      return
    }

    XCTAssertFalse(type(of: genericView) === ListWrapper.self)
    XCTAssertTrue(type(of: genericView) === TestView.self)
  }
}
