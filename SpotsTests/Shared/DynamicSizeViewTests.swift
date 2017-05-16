import XCTest
import Spots

#if os(macOS)
  typealias ListView = NSTableRowView
  typealias GridView = NSView
#else
  typealias ListView = UITableViewCell
  typealias GridView = UICollectionViewCell
#endif

class DynamicWrappedViewMock: View, ItemConfigurable, DynamicSizeView {

  var preferredViewSize: CGSize = CGSize(width: 100, height: 100)

  func computeSize(for item: Item) -> CGSize {
    return CGSize(width: 200, height: 200)
  }

  func configure(with item: Item) {}
}

class DynamicListViewMock: ListView, ItemConfigurable, DynamicSizeView {

  var preferredViewSize: CGSize = CGSize(width: 100, height: 100)

  func computeSize(for item: Item) -> CGSize {
    return CGSize(width: 300, height: 300)
  }

  func configure(with item: Item) {}
}

class DynamicGridViewMock: GridView, ItemConfigurable, DynamicSizeView {

  var preferredViewSize: CGSize = CGSize(width: 100, height: 100)

  func computeSize(for item: Item) -> CGSize {
    return CGSize(width: 150, height: 150)
  }

  func configure(with item: Item) {}
}


class DynamicSizeViewTests: XCTestCase {

  enum Identifier: String {
    case wrapped, list, grid
  }

  override func setUp() {
    Configuration.register(view: DynamicWrappedViewMock.self, identifier: Identifier.wrapped.rawValue)
    Configuration.register(view: DynamicListViewMock.self, identifier: Identifier.list.rawValue)
    Configuration.register(view: DynamicGridViewMock.self, identifier: Identifier.grid.rawValue)
  }

  func testWrappedDynamicViewInGrid() {
    let component = createComponent(kind: .grid, items: [Item(kind: Identifier.wrapped.rawValue)])
    XCTAssertEqual(component.model.items[0].size, CGSize(width: 200, height: 200))
  }

  func testWrappedDynamicViewInList() {
    let component = createComponent(kind: .list, items: [Item(kind: Identifier.wrapped.rawValue)])
    XCTAssertEqual(component.model.items[0].size, CGSize(width: 200, height: 200))
  }

  func testDynamicListView() {
    let component = createComponent(kind: .list, items: [Item(kind: Identifier.list.rawValue)])
    XCTAssertEqual(component.model.items[0].size, CGSize(width: 300, height: 300))

    let type: DynamicListViewMock? = component.ui(at: 0)
    XCTAssertNotNil(type)
    let expectation = self.expectation(description: "Wait for component update")
    component.update(Item(kind: Identifier.wrapped.rawValue), index: 0) {
      XCTAssertEqual(component.model.items[0].kind, Identifier.wrapped.rawValue)
      XCTAssertEqual(component.model.items[0].size, CGSize(width: 200, height: 200))
      let type: DynamicWrappedViewMock? = component.ui(at: 0)
      XCTAssertNotNil(type)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testDynamicGridView() {
    let component = createComponent(kind: .grid, items: [Item(kind: Identifier.grid.rawValue)])
    XCTAssertEqual(component.model.items[0].size, CGSize(width: 150, height: 150))

    let expectation = self.expectation(description: "Wait for component update")
    component.update(Item(kind: Identifier.wrapped.rawValue), index: 0) {
      XCTAssertEqual(component.model.items[0].kind, Identifier.wrapped.rawValue)
      XCTAssertEqual(component.model.items[0].size, CGSize(width: 200, height: 200))
      let type: DynamicWrappedViewMock? = component.ui(at: 0)
      XCTAssertNotNil(type)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 10.0, handler: nil)
  }

  private func createComponent(kind: ComponentKind, items: [Item]) -> Component {
    let model = ComponentModel(kind: kind, items: items)
    let component = Component(model: model)
    component.setup(with: .init(width: 200, height: 200))
    return component
  }
}
