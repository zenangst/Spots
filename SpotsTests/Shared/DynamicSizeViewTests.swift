import XCTest
import Spots

class DynamicSizeViewMock: View, ItemConfigurable, DynamicSizeView {

  var preferredViewSize: CGSize = CGSize(width: 100, height: 100)

  func computeSize(for item: Item) -> CGSize {
    return CGSize(width: 200, height: 200)
  }

  func configure(with item: Item) {}
}

class DynamicSizeViewTests: XCTestCase {

  func testDynamicSizeView() {
    Configuration.registerDefault(view: DynamicSizeViewMock.self)

    let model = ComponentModel(items: [Item(title: "foo")])
    let component = Component(model: model)
    component.setup(with: .init(width: 200, height: 200))

    XCTAssertEqual(component.model.items[0].size, CGSize(width: 200, height: 200))
  }
}
