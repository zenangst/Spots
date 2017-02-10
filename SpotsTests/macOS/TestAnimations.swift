@testable import Spots
import Cocoa
import XCTest

class AnimationTests: XCTestCase {

  func testResolvingAnimations() {
    XCTAssertEqual(Animation.automatic.tableViewAnimation, NSTableViewAnimationOptions.effectFade)
    XCTAssertEqual(Animation.fade.tableViewAnimation, NSTableViewAnimationOptions.effectFade)
    XCTAssertEqual(Animation.right.tableViewAnimation, NSTableViewAnimationOptions.slideRight)
    XCTAssertEqual(Animation.left.tableViewAnimation, NSTableViewAnimationOptions.slideLeft)
    XCTAssertEqual(Animation.top.tableViewAnimation, NSTableViewAnimationOptions.slideUp)
    XCTAssertEqual(Animation.bottom.tableViewAnimation, NSTableViewAnimationOptions.slideDown)
    XCTAssertEqual(Animation.middle.tableViewAnimation, NSTableViewAnimationOptions.effectGap)
  }
}
