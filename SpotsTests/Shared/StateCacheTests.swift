@testable import Spots
import Foundation
import XCTest

class StateCacheTests: XCTestCase {
  let cacheKey: String = "state-cache-test"
  var controller: SpotsController!

  override func setUp() {
    StateCache.removeAll()
    controller = SpotsController(cacheKey: cacheKey)
  }

  override func tearDown() {
    controller = nil
  }

  func testStateCacheName() {
    XCTAssertEqual(controller.stateCache!.fileName(), "1602c56d3ac0f61e5129b5915cccca7b".uppercased())
  }

  func testStateCacheOnController() {
    /// Check that cache exists
    XCTAssertNotNil(controller.stateCache)
    /// Check that cache is empty
    XCTAssertEqual(loadComponentModelsDictionary().count, 0)

    controller.components = [Component(model: ComponentModel(layout: Layout(span: 1.0)))]

    let expectation = self.expectation(description: "Append item to CoreComponent object")
    controller.append(Item(title: "foo"), componentIndex: 0, withAnimation: .automatic) {
      self.controller.cache()
      /// Check that the cache was saved to disk
      XCTAssertEqual(self.loadComponentModelsDictionary().count, 1)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testRemovingStateCacheFromController() {
    let expectation = self.expectation(description: "Clear state cache")
    controller.stateCache?.clear() {
      XCTAssertEqual(self.loadComponentModelsDictionary().count, 0)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testCacheWithEmptyKey() {
    /// Expect to generate a MD5 hash from an empty key
    let stateCache = StateCache(key: "")
    XCTAssertNotEqual(stateCache.fileName(), "")
  }

  private func loadComponentModelsDictionary() -> [String: [ComponentModel]] {
    guard let stateCache = controller.stateCache else {
      return [:]
    }

    let dictionary: [String: [ComponentModel]] = stateCache.load() ?? [:]
    return dictionary
  }
}
