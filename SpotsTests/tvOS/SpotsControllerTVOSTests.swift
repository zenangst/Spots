@testable import Spots
import XCTest

class SpotsControllerTVOSTests: XCTestCase {

  func testConfigureFocusGuide() {
    let controller = SpotsController()

    // By default, the focus guide should not be enabled
    // nor should it have an owning view until `viewDidLoad()` is invoked.
    XCTAssertFalse(controller.focusGuide.isEnabled)
    XCTAssertNil(controller.focusGuide.owningView)

    let _ = controller.view

    // After `viewDidLoad()`, the focus guide should still be disabled but it
    // should use `controller.scrollView` as its default owning view.
    XCTAssertFalse(controller.focusGuide.isEnabled)
    XCTAssertEqual(controller.focusGuide.owningView, controller.scrollView)

    controller.scrollView.removeLayoutGuide(controller.focusGuide)

    // Test manually configuring the focus guide by invoking the method directly and
    // default to the focus guide being active.
    controller.configure(focusGuide: controller.focusGuide, for: controller.scrollView, enabled: true)

    XCTAssertTrue(controller.focusGuide.isEnabled)
    XCTAssertEqual(controller.focusGuide.owningView, controller.scrollView)
  }

}
