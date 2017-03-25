@testable import Spots
import Foundation
import XCTest

class AnimationTests: XCTestCase {

  func testResolvingAnimations() {
    XCTAssertEqual(Animation.automatic.tableViewAnimation, UITableViewRowAnimation.automatic)
    XCTAssertEqual(Animation.fade.tableViewAnimation, UITableViewRowAnimation.fade)
    XCTAssertEqual(Animation.right.tableViewAnimation, UITableViewRowAnimation.right)
    XCTAssertEqual(Animation.left.tableViewAnimation, UITableViewRowAnimation.left)
    XCTAssertEqual(Animation.top.tableViewAnimation, UITableViewRowAnimation.top)
    XCTAssertEqual(Animation.bottom.tableViewAnimation, UITableViewRowAnimation.bottom)
    XCTAssertEqual(Animation.none.tableViewAnimation, UITableViewRowAnimation.none)
    XCTAssertEqual(Animation.middle.tableViewAnimation, UITableViewRowAnimation.middle)
  }
}
