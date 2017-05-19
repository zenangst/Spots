@testable import Spots
import Foundation
import XCTest

class ItemsPerRowViewMock: View, ItemConfigurable {

  func configure(with item: Item) {}

  func computeSize(for item: Item) -> CGSize {
    return CGSize(width: 100, height: 50)
  }
}

class TestGridableLayout: XCTestCase {

  override func setUp() {
    Configuration.registerDefault(view: ItemsPerRowViewMock.self)
    Configuration.views.purge()
  }

  func testItemsPerRow() {
    var component: Component
    var model: ComponentModel
    let items = [
      Item(title: "Item 1"),
      Item(title: "Item 2"),
      Item(title: "Item 3"),
      Item(title: "Item 4"),
      Item(title: "Item 5"),
      Item(title: "Item 6"),
      Item(title: "Item 7"),
      Item(title: "Item 8"),
      Item(title: "Item 9"),
      Item(title: "Item 10"),
      Item(title: "Item 11"),
      Item(title: "Item 12"),
      Item(title: "Item 13"),
      Item(title: "Item 14"),
      Item(title: "Item 15"),
      ]

    model = ComponentModel(kind: .carousel, layout: Layout(itemsPerRow: 1), items: items)
    component = Component(model: model)
    component.setup(with: CGSize(width: 100, height: 100))

    var gridableLayout = component.collectionView?.collectionViewLayout as? GridableLayout
    XCTAssertEqual(gridableLayout?.contentSize, CGSize(width: 1500, height: 50))

    model = ComponentModel(kind: .carousel, layout: Layout(itemsPerRow: 2), items: items)
    component = Component(model: model)
    component.setup(with: CGSize(width: 100, height: 100))
    gridableLayout = component.collectionView?.collectionViewLayout as? GridableLayout

    XCTAssertEqual(gridableLayout?.contentSize, CGSize(width: 800, height: 100))

    model = ComponentModel(kind: .carousel, layout: Layout(itemsPerRow: 3), items: items)
    component = Component(model: model)
    component.setup(with: CGSize(width: 100, height: 100))
    gridableLayout = component.collectionView?.collectionViewLayout as? GridableLayout

    XCTAssertEqual(gridableLayout?.contentSize, CGSize(width: 500, height: 150))
  }
  
}
