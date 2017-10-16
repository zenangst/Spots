@testable import Spots
import Foundation
import XCTest

class ItemManagerTests: XCTestCase {

  func testSizeForItem() {
    let items = [
      Item(size: CGSize(width: 100, height: 100)),
      Item(size: CGSize(width: 100, height: -100)),
    ]
    let model = ComponentModel(kind: .grid, items: items)
    let component = Component(model: model)

    // Should return the same size as the item.
    XCTAssertEqual(component.sizeForItem(at: IndexPath(item: 0, section: 0)),
                   CGSize(width: 100, height: 100))
    // Should never return a negative value.
    XCTAssertEqual(component.sizeForItem(at: IndexPath(item: 1, section: 0)),
                   CGSize(width: 100, height: 0))

    component.setup(with: CGSize(width: 100, height: 100))
    // When an item is prepared, the item should be larger than zero.
    XCTAssertTrue(component.sizeForItem(at: IndexPath(item: 1, section: 0)).height > 0)
  }

  func testComputingItemChange() {
    let manager = ItemManager()

    do {
      let a = Item()
      let b = Item()
      XCTAssertEqual(manager.computeChange(between: a, and: b), .soft)
    }

    do {
      let a = Item(size: CGSize(width: 100, height: 100))
      let b = Item(size: CGSize(width: 100, height: 200))
      XCTAssertEqual(manager.computeChange(between: a, and: b), .medium)
    }

    do {
      let a = Item(kind: "a")
      let b = Item(kind: "b")
      XCTAssertEqual(manager.computeChange(between: a, and: b), .hard)
    }
  }
}
