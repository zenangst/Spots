@testable import Spots
import Cocoa
import XCTest

class AnimationTests: XCTestCase {

  func testResolvingAnimations() {
    XCTAssertEqual(Animation.automatic.tableViewAnimation, NSTableView.AnimationOptions.effectFade)
    XCTAssertEqual(Animation.fade.tableViewAnimation, NSTableView.AnimationOptions.effectFade)
    XCTAssertEqual(Animation.right.tableViewAnimation, NSTableView.AnimationOptions.slideRight)
    XCTAssertEqual(Animation.left.tableViewAnimation, NSTableView.AnimationOptions.slideLeft)
    XCTAssertEqual(Animation.top.tableViewAnimation, NSTableView.AnimationOptions.slideUp)
    XCTAssertEqual(Animation.bottom.tableViewAnimation, NSTableView.AnimationOptions.slideDown)
    XCTAssertEqual(Animation.middle.tableViewAnimation, NSTableView.AnimationOptions.effectGap)
  }
}
