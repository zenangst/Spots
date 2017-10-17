@testable import Spots
import Foundation
import XCTest

class SpotsScrollViewTests: XCTestCase {

  func testStetchLastComponent() {
    let items = [Item(), Item()]
    let model = ComponentModel(layout: Layout(span: 1), items: items)
    let controller = SpotsController(components: [Component(model: model), Component(model: model), Component(model: model)])
    controller.prepareController()
    controller.view.frame.size = CGSize(width: 100, height: 600)
    controller.scrollView.layoutViews()

    /// The first and the last component should be equal in height
    XCTAssertEqual(controller.components.first?.view.frame.size, controller.components.last?.view.frame.size)

    controller.scrollView.configuration.stretchLastComponent = true
    controller.scrollView.layoutViews()

    /// The first and last component should not be equal as the last one should be stretched.
    XCTAssertNotEqual(controller.components.first?.view.frame.size, controller.components.last?.view.frame.size)

    var totalComponentHeight: CGFloat = 0.0
    for component in controller.components {
      totalComponentHeight += component.view.frame.size.height
    }

    XCTAssertEqual(controller.scrollView.frame.size.height, totalComponentHeight)
  }
}
