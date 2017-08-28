@testable import Spots
import XCTest

class ComponentMacOSTests: XCTestCase {
  class ComponentTestView: View, ItemConfigurable {
    func configure(with item: Item) {}
    func computeSize(for item: Item, containerSize: CGSize) -> CGSize {
      return CGSize(width: 100, height: 100)
    }
  }

  func testComponentComputedHeightConstraint() {
    let identifier = "testComponentComputedHeightConstraint"
    Configuration.register(view: ComponentTestView.self, identifier: identifier)
    let items = [
      Item(kind: identifier),
      Item(kind: identifier),
      Item(kind: identifier),
      Item(kind: identifier),
      Item(kind: identifier),
      Item(kind: identifier),
      ]
    let model = ComponentModel(kind: .grid, items: items)
    let component = Component(model: model)
    let controller = SpotsController(components: [component])
    controller.prepareController()
    let expectation = self.expectation(description: "Expect comonent to have the same height as the enclosing scroll view.")

    component.updateHeight {
      XCTAssertEqual(controller.scrollView.frame.size.height, component.view.frame.size.height)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10.0)
  }
}
