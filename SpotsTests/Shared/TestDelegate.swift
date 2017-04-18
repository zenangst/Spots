import XCTest
import Spots

class TestDelegate: XCTestCase {

  func testWillDisplayInList() {
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
  }

  func testWillDisplayInGrid() {
    let items = [
      Item(title: "foo"),
      Item(title: "bar"),
      Item(title: "baz")
    ]
    let model = ComponentModel(kind: .grid, items: items)
    let component = Component(model: model)

    var invocations: Int = 0

    component.configure = { item in
      invocations += 1
    }

    component.setup(with: CGSize(width: 200, height: 200))
    XCTAssertEqual(invocations, 3)
  }
}
