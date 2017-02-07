@testable import Spots
import Brick
import XCTest

class TestSpot: XCTestCase {

  override func setUp() {
    Configuration.views.storage = [:]
    Configuration.views.defaultItem = nil
  }

  func testDefaultValues() {
    let items = [Item(title: "A"), Item(title: "B")]
    let component = Component(items: items, hybrid: true)
    let spot = Spot(component: component)

    spot.setup(CGSize(width: 100, height: 100))

    XCTAssertTrue(spot.view is TableView)
    XCTAssertTrue(spot.view.isEqual(spot.tableView))
    XCTAssertEqual(spot.items[0].size,    CGSize(width: 414, height: 44))
    XCTAssertEqual(spot.items[1].size,    CGSize(width: 414, height: 44))
    XCTAssertEqual(spot.view.contentSize, CGSize(width: 100, height: 88))
  }
}
