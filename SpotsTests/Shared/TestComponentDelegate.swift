import XCTest
import Spots

class MockComponentDelegate: ComponentDelegate {

  var testClosure: ((MockComponentDelegate) -> Void)?
  var expectation: XCTestExpectation?
  var didDisplayCorrectView: Bool = false
  var didEndDisplayCorrectView: Bool = false {
    didSet {
      testClosure?(self)
      expectation?.fulfill()
    }
  }

  func component(_ component: Component, willDisplay view: ComponentView, item: Item) {
    didDisplayCorrectView = view is DefaultItemView
  }

  func component(_ component: Component, didEndDisplaying view: ComponentView, item: Item) {
    didEndDisplayCorrectView = view is DefaultItemView
  }
}

class TestComponentDelegate: XCTestCase {

  var mockDelegate: MockComponentDelegate!

  override func setUp() {
    mockDelegate = MockComponentDelegate()
    Configuration.registerDefault(view: DefaultItemView.self)
  }

  func testComponentWillDisplayAndEndDisplay() {
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    let model = ComponentModel(kind: .grid, layout: Layout(span: 1), items: items)
    let component = Component(model: model)
    let controller = SpotsController(components: [component])
    controller.delegate = mockDelegate
    controller.prepareController()

    XCTAssertTrue(mockDelegate.didDisplayCorrectView)
    mockDelegate.testClosure = { mockDelegate in
      XCTAssertTrue(mockDelegate.didEndDisplayCorrectView)
    }

    mockDelegate.expectation = self.expectation(description: "Wait for mutation")
    controller.delete(0, componentIndex: 0, withAnimation: .automatic)

    waitForExpectations(timeout: 10.0, handler: nil)
  }
}
