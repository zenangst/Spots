@testable import Spots
import Foundation
import XCTest

class DiffManagerTests: XCTestCase {

  var manager: DiffManager!

  override func setUp() {
    manager = DiffManager()
  }

  func testComparingItemsWithoutChanges() {
    let lhs = [Item(title: "foo")]
    let rhs = [Item(title: "foo")]

    XCTAssertNil(manager.compare(oldItems: lhs, newItems: rhs))
  }

  func testComparingSimpleUpdate() {
    let lhs = [Item(title: "foo")]
    let rhs = [Item(title: "bar")]
    let changes = manager.compare(oldItems: lhs, newItems: rhs)!

    XCTAssertEqual(changes.insertions.count, 0)
    XCTAssertTrue(changes.updates.contains(0))
    XCTAssertEqual(changes.updates.count, 1)
    XCTAssertEqual(changes.reloads.count, 0)
    XCTAssertEqual(changes.deletions.count, 0)
    XCTAssertEqual(changes.childUpdates.count, 0)
    XCTAssertEqual(changes.moved.count, 0)
  }

  func testComparingDifferentKind() {
    let lhs = [Item(kind: "foo")]
    let rhs = [Item(kind: "bar")]
    let changes = manager.compare(oldItems: lhs, newItems: rhs)!

    XCTAssertEqual(changes.insertions.count, 0)
    XCTAssertEqual(changes.updates.count, 0)
    XCTAssertTrue(changes.reloads.contains(0))
    XCTAssertEqual(changes.reloads.count, 1)
    XCTAssertEqual(changes.deletions.count, 0)
    XCTAssertEqual(changes.childUpdates.count, 0)
    XCTAssertEqual(changes.moved.count, 0)
  }

  func testComparingDifferentSize() {
    let lhs = [Item(size: .init(width: 200, height: 200))]
    let rhs = [Item(size: .init(width: 100, height: 100))]
    let changes = manager.compare(oldItems: lhs, newItems: rhs)!

    XCTAssertEqual(changes.insertions.count, 0)
    XCTAssertEqual(changes.updates.count, 0)
    XCTAssertTrue(changes.reloads.contains(0))
    XCTAssertEqual(changes.reloads.count, 1)
    XCTAssertEqual(changes.deletions.count, 0)
    XCTAssertEqual(changes.childUpdates.count, 0)
    XCTAssertEqual(changes.moved.count, 0)
  }

  func testComparingNewItems() {
    let lhs = [Item(title: "a")]
    let rhs = [
      Item(title: "a"),
      Item(title: "b"),
      Item(title: "c"),
    ]
    let changes = manager.compare(oldItems: lhs, newItems: rhs)!

    XCTAssertEqual(changes.insertions.count, 2)
    XCTAssertTrue(changes.insertions.contains(1))
    XCTAssertTrue(changes.insertions.contains(2))
    XCTAssertEqual(changes.updates.count, 0)
    XCTAssertEqual(changes.reloads.count, 0)
    XCTAssertEqual(changes.deletions.count, 0)
    XCTAssertEqual(changes.childUpdates.count, 0)
    XCTAssertEqual(changes.moved.count, 0)
  }

  func testComparingWhenRemovingItems() {
    let lhs = [
      Item(title: "a"),
      Item(title: "b"),
      Item(title: "c"),
      ]
    let rhs = [Item(title: "a")]
    let changes = manager.compare(oldItems: lhs, newItems: rhs)!

    XCTAssertEqual(changes.insertions.count, 0)
    XCTAssertEqual(changes.updates.count, 0)
    XCTAssertEqual(changes.reloads.count, 0)
    XCTAssertEqual(changes.deletions.count, 2)
    XCTAssertTrue(changes.deletions.contains(1))
    XCTAssertTrue(changes.deletions.contains(2))
    XCTAssertEqual(changes.childUpdates.count, 0)
    XCTAssertEqual(changes.moved.count, 0)
  }

  func testComparingWhenMovingItems() {
    let lhs = [
      Item(title: "a"),
      Item(title: "b"),
      Item(title: "c"),
      ].refreshIndexes()
    let rhs = Array(lhs.reversed())

    let changes = manager.compare(oldItems: lhs, newItems: rhs)!

    XCTAssertEqual(changes.insertions.count, 0)
    XCTAssertEqual(changes.updates.count, 0)
    XCTAssertEqual(changes.reloads.count, 0)
    XCTAssertEqual(changes.deletions.count, 0)
    XCTAssertEqual(changes.childUpdates.count, 0)
    XCTAssertEqual(changes.moved.count, 2)
    XCTAssertEqual(changes.moved[0], 2)
    XCTAssertEqual(changes.moved[2], 0)
  }
}
