@testable import Spots
import Foundation
import XCTest

class UIViewControllerExtensionsTests: XCTestCase {

  var controller: SpotsController!

  override func setUp() {
    controller = SpotsController(components: [])
  }

  override func tearDown() {
    controller = nil
  }

  func testShouldAutorotateOnController() {
    XCTAssertEqual(controller.components_shouldAutorotate(), true)
  }

  func testShouldAutorotateOnChildController() {
    let parentController = UIViewController()
    parentController.addChildViewController(controller)
    XCTAssertEqual(controller.components_shouldAutorotate(), true)
  }
}
