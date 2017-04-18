import XCTest
import Spots

class DelegateConfigurationClosureTests: XCTestCase {

  func testConfigureCalledOncePerSetupInListComponent() {
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    let model = ComponentModel(kind: .list, items: items)
    let component = Component(model: model)

    var invocations: Int = 0

    component.configure = { item in
      invocations += 1
    }

    component.setup(with: CGSize(width: 200, height: 200))

    XCTAssertEqual(invocations, 3)

    /// Verify that the configuration closure is called again when you reassign it.
    component.configure = { item in
      invocations += 1
    }

    XCTAssertEqual(invocations, 6)
  }

  func testConfigureCalledOncePerSetupInGridComponent() {
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    let model = ComponentModel(kind: .grid, items: items)
    let component = Component(model: model)

    var invocations: Int = 0

    /// Verify that the configuration closure is called again when you reassign it.
    component.configure = { item in
      invocations += 1
    }

    component.setup(with: CGSize(width: 200, height: 200))
    XCTAssertEqual(invocations, 3)

    component.configure = { item in
      invocations += 1
    }

    XCTAssertEqual(invocations, 6)
  }
}
