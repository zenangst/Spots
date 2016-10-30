@testable import Spots
import Foundation
import XCTest
import Brick

class StateCacheTests : XCTestCase {

  let cacheKey: String = "state-cache-test"
  var controller: Controller!

  override func setUp() {
    controller = Controller(cacheKey: cacheKey)
  }

  override func tearDown() {
    controller = nil
  }

  func testStateCacheName() {
    XCTAssertEqual(controller.stateCache!.fileName(), "1602c56d3ac0f61e5129b5915cccca7b")
  }

  func testStateCacheOnController() {
    /// Check that cache exists
    XCTAssertNotNil(controller.stateCache)
    /// Check that cache is empty
    XCTAssertEqual(controller.stateCache!.load().count, 0)

    controller.spots = [ListSpot(component: Component())]

    let exception = self.expectation(description: "Append item to Spotable object")
    controller.append(Item(title: "foo"), spotIndex: 0, withAnimation: .automatic) {
      self.controller.cache()
      /// Check that the cache was saved to disk
      XCTAssertEqual(self.controller.stateCache!.load().count, 1)
      exception.fulfill()
    }
    waitForExpectations(timeout: 1.0, handler: nil)
  }

  func testRemovingStateCacheFromController() {
    XCTAssert(controller.stateCache!.load().count != 0)
    XCTAssertEqual(controller.stateCache!.cacheExists, true)

    let exception = self.expectation(description: "Clear state cache")
    controller.stateCache?.clear {
      XCTAssertEqual(self.controller.stateCache!.load().count, 0)
      XCTAssertEqual(self.controller.stateCache!.cacheExists, false)
      exception.fulfill()
    }
    waitForExpectations(timeout: 1.0, handler: nil)
  }
}
