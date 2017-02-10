@testable import Spots
import Foundation
import XCTest

class StateCacheTests: XCTestCase {

  let cacheKey: String = "state-cache-test"
  var controller: Controller!

  override func setUp() {
    StateCache.removeAll()
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

    controller.spots = [ListSpot(component: Component(span: 1.0))]

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
    let exception = self.expectation(description: "Clear state cache")
    controller.stateCache?.clear {
      XCTAssertEqual(self.controller.stateCache!.load().count, 0)
      XCTAssertEqual(self.controller.stateCache!.cacheExists, false)
      exception.fulfill()
    }
    waitForExpectations(timeout: 1.0, handler: nil)
  }

  func testCacheWithEmptyKey() {
    /// Expect to generate a MD5 hash from an empty key
    let stateCache = StateCache(key: "")
    XCTAssertNotEqual(stateCache.fileName(), "")
  }

  func testRemoveAll() {
    let cacheOne = StateCache(key: "one")
    let cacheTwo = StateCache(key: "two")
    let path = cacheOne.path

    [cacheOne, cacheTwo].forEach { $0.save(["foo": "bar"]) }

    let exception = self.expectation(description: "Wait for cache")
    Dispatch.after(seconds: 0.5) {
      do {
        let files = try FileManager.default.contentsOfDirectory(atPath: path)
        XCTAssertEqual(files.count, 2)
      } catch {}

      StateCache.removeAll()

      do {
        let files = try FileManager.default.contentsOfDirectory(atPath: path)
        XCTAssertEqual(files.count, 0)
      } catch {}

      exception.fulfill()
    }
    waitForExpectations(timeout: 1.0, handler: nil)
  }
}
