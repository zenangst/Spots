import XCTest
@testable import Spots

class ComponentResolvableTests: XCTestCase {
  func testResolvingComponents() {
    let component = Component(model: ComponentModel())
    let dataSource = DataSource(component: component)

    dataSource.resolveComponent { resolvedComponent in
      XCTAssertEqual(component, resolvedComponent)
    }

    dataSource.resolveComponentItem(at: IndexPath(item: 0, section: 0)) { _ in
      XCTFail("The component item should not be resolved because the component does not have any items.")
    }

    let expectation = self.expectation(description: "Wait for the component to reload.")
    let item = Item()
    component.insert(item, index: 0) {
      dataSource.resolveComponentItem(at: IndexPath(item: 0, section: 0)) { resolvedComponent, resolvedItem in
        XCTAssertEqual(component, resolvedComponent)
        XCTAssertNotNil(resolvedItem)
      }
      expectation.fulfill()
    }

    let fallbackComponent = component
    dataSource.component = nil
    let resolvedFallbackComponent: Component = dataSource.resolveComponent({ (component) -> Component in
      return component
    }, fallback: fallbackComponent)
    XCTAssertEqual(resolvedFallbackComponent, fallbackComponent)

    dataSource.component = fallbackComponent
    let resolvedComponent: Component = dataSource.resolveComponent({ (component) -> Component in
      return component
    }, fallback: fallbackComponent)
    XCTAssertEqual(resolvedComponent, fallbackComponent)

    waitForExpectations(timeout: 10.0, handler: nil)
  }
}
