@testable import Spots
import XCTest

class SpotsScrollViewTVOSTests: XCTestCase {

  func testSpotsScrollViewHeight() {
    let model = ComponentModel(
      items: [
        Item(),
        Item(),
        Item(),
        Item()
      ]
    )
    let components = [Component(model: model)]
    let controller = SpotsController(components: components)
    controller.prepareController()

    // With only one component, the content size height should be equal to the scroll views frame height.
    XCTAssertEqual(controller.scrollView.frame.height, controller.scrollView.contentSize.height)
  }
}
