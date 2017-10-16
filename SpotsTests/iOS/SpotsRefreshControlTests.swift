import XCTest
@testable import Spots

class SpotsRefreshControlTests: XCTestCase {
  func testEndRefreshing() {
    let refreshControl = SpotsRefreshControl()
    refreshControl.frame.size = CGSize(width: 50, height: 50)
    refreshControl.beginRefreshing()

    XCTAssertTrue(refreshControl.isRefreshing)
    XCTAssertFalse(refreshControl.isHidden)

    refreshControl.endRefreshing()
    XCTAssertFalse(refreshControl.isRefreshing)
    XCTAssertTrue(refreshControl.isHidden)

    refreshControl.isHidden = false
    refreshControl.endRefreshing()
    XCTAssertFalse(refreshControl.isHidden)
  }
}
