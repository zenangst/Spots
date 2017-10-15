import XCTest
@testable import Spots

class DataSourceTests: XCTestCase {
  func testNumberOfItems() {
    let model = ComponentModel(items: [])
    let component = Component(model: model)
    let dataSource = DataSource(component: component)

    XCTAssertEqual(dataSource.numberOfItems, model.items.count)

    let expectation = self.expectation(description: "Expect .numberOfItems to be the same as the model")
    component.append([Item(), Item(), Item()]) {
      XCTAssertEqual(dataSource.numberOfItems, component.model.items.count)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }
}
