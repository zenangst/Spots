@testable import Spots
import Foundation
import XCTest

class CoreComponentTests: XCTestCase {

  func testAppendingMultipleItemsToComponent() {
    let listComponent = ListComponent(model: ComponentModel(kind: .list, layout: Layout(span: 1)))
    listComponent.setup(with: CGSize(width: 100, height: 100))
    var items: [Item] = []

    for i in 0..<10 {
      items.append(Item(title: "Item: \(i)"))
    }

    measure {
      for _ in 0..<5 {
        listComponent.append(items)
        listComponent.view.layoutSubviews()
      }
    }

    let expectation = self.expectation(description: "Wait until done")
    Dispatch.after(seconds: 1.0) {
      XCTAssertEqual(listComponent.model.items.count, 500)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testAppendingMultipleItemsToSpotInController() {
    let controller = SpotsController(components: [ListComponent(model: ComponentModel(kind: .list, layout: Layout(span: 1.0)))])
    controller.prepareController()
    var items: [Item] = []

    for i in 0..<10 {
      items.append(Item(title: "Item: \(i)"))
    }

    measure {
      for _ in 0..<5 {
        controller.append(items, componentIndex: 0, withAnimation: .automatic, completion: nil)
        controller.components.forEach { $0.view.layoutSubviews() }
      }
    }

    let expectation = self.expectation(description: "Wait until done")
    Dispatch.after(seconds: 1.0) {
      XCTAssertEqual(controller.components[0].model.items.count, 500)
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testResolvingUIFromGridableComponent() {
    let kind = "test-view"

    Configuration.register(view: TestView.self, identifier: kind)

    let parentSize = CGSize(width: 100, height: 100)
    let model = ComponentModel(items: [Item(title: "foo", kind: kind)])
    let component = GridComponent(model: model)
    component.view.frame.size = parentSize
    component.setup(with: parentSize)
    component.layout(with: parentSize)
    component.view.layoutIfNeeded()

    guard let genericView: View = component.ui(at: 0) else {
      XCTFail()
      return
    }

    XCTAssertFalse(type(of: genericView) === GridWrapper.self)
    XCTAssertTrue(type(of: genericView) === TestView.self)
  }

  func testResolvingUIFromListableComponent() {
    let kind = "test-view"

    Configuration.register(view: TestView.self, identifier: kind)

    let parentSize = CGSize(width: 100, height: 100)
    let model = ComponentModel(items: [Item(title: "foo", kind: kind)])
    let component = ListComponent(model: model)

    component.setup(with: parentSize)
    component.layout(with: parentSize)
    component.view.layoutSubviews()

    guard let genericView: View = component.ui(at: 0) else {
      XCTFail()
      return
    }

    XCTAssertFalse(type(of: genericView) === ListWrapper.self)
    XCTAssertTrue(type(of: genericView) === TestView.self)
  }

  func testCarouselComponentConfigurationClosure() {
    Configuration.register(view: TestView.self, identifier: "test-view")

    let items = [Item(title: "Item A", kind: "test-view"), Item(title: "Item B")]
    let component = CarouselComponent(model: ComponentModel(kind: .carousel, layout: Layout(span: 0.0), items: items))
    component.setup(with: CGSize(width: 100, height: 100))

    var invokeCount = 0
    component.configure = { _ in
      invokeCount += 1
    }

    // This should be invoked twice, once for each view.
    XCTAssertEqual(invokeCount, 2)
  }

  func testListComponentConfigurationClosure() {
    Configuration.register(view: TestView.self, identifier: "test-view")

    let items = [Item(title: "Item A", kind: "test-view"), Item(title: "Item B")]
    let component = CarouselComponent(model: ComponentModel(kind: .list, items: items))
    component.setup(with: CGSize(width: 100, height: 100))

    var invokeCount = 0
    component.configure = { _ in
      invokeCount += 1
    }

    // This should be invoked twice, once for each view.
    XCTAssertEqual(invokeCount, 2)
  }
}
