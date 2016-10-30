@testable import Spots
import Foundation
import XCTest
import Brick

class UIViewControllerExtensionsTests: XCTestCase {

  var controller: Controller!

  override func setUp() {
    controller = Controller(spots: [])
  }

  override func tearDown() {
    controller = nil
  }

  func testShouldAutorotateOnController() {
    XCTAssertEqual(controller.spots_shouldAutorotate(), true)
  }

  func testShouldAutorotateOnChildController() {
    let parentController = UIViewController()
    parentController.addChildViewController(controller)
    XCTAssertEqual(controller.spots_shouldAutorotate(), true)
  }
}
