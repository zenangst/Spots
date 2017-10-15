import XCTest
@testable import Spots

class ArrayExtensionsTests: XCTestCase {
  func testRefreshIndexesWithElementItem() {
    var items: [Item] = [Item(), Item(), Item()]
    let initialIndexes = items.map { $0.index }
    XCTAssertEqual(initialIndexes, [0,0,0])

    items = items.refreshIndexes()
    let refreshedIndexes = items.map { $0.index }
    XCTAssertEqual(refreshedIndexes, [0,1,2])
  }

  func testRefreshIndexesInOptionalArrayOfItem() {
    var items: [Item]? = [Item(), Item(), Item()]
    let initialIndexes = items?.map { $0.index }
    XCTAssertEqual(initialIndexes!, [0,0,0])

    items = items?.refreshIndexes()
    let refreshedIndexes = items?.map { $0.index }
    XCTAssertEqual(refreshedIndexes!, [0,1,2])
  }
}
