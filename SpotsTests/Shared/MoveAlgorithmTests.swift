@testable import Spots
import Foundation
import XCTest

/// MoveAlgorithm returns a dictionary with results.
/// The key for each value represents the previous index the the value represents the new index.
class MoveAlgorithmTests: XCTestCase {

  let algorithm = MoveAlgorithm()

  func testCalculateMoveForInsertedIndexes() {
    // If there are no indexes, the method should return early and returns an empty dictionary.
    XCTAssertEqual(algorithm.calculateMoveForInsertedIndexes([], numberOfItems: 1), [:])
    // Inserting a new item in the beginning of the collection means that all the existing items need
    // to move, all of them should have a larger index than before.
    XCTAssertEqual(algorithm.calculateMoveForInsertedIndexes([0], numberOfItems: 3), [0: 1, 1: 2, 2: 3])
    // Inserting a new item at the end of the collection should not affect the current collection.
    XCTAssertEqual(algorithm.calculateMoveForInsertedIndexes([3], numberOfItems: 3), [:])
    // Inserting a new item at index two should result in the last item in the collection moving into a new location.
    XCTAssertEqual(algorithm.calculateMoveForInsertedIndexes([2], numberOfItems: 3), [2: 3])
    // Inserting new items in the middle of a collectino will result in the items contained after the
    // last inserted index should relocate with a new index that is higher than the one it previously had.
    XCTAssertEqual(algorithm.calculateMoveForInsertedIndexes([3, 4, 5], numberOfItems: 9), [3: 6, 4: 7, 5: 8, 6: 9, 7: 10, 8: 11])
    // Inserting three new indexes with one existing item should result in the the first one being moved to the end.
    XCTAssertEqual(algorithm.calculateMoveForInsertedIndexes([0,1,2], numberOfItems: 1), [0: 3])
  }

  func testCalculateMoveForDeletedIndexes() {
    // We remove the first item, the second and third item should then move from 2 to 1 and 1 to 0.
    XCTAssertEqual(algorithm.calculateMoveForDeletedIndexes([0], numberOfItems: 3), [2: 1, 1: 0])
    // We remove the second item, the first should be unaffected but the last one should move to a new position.
    XCTAssertEqual(algorithm.calculateMoveForDeletedIndexes([1], numberOfItems: 3), [2: 1])
    // Removing the first and last indexes means that the item at index zero should be moved to the first position.
    XCTAssertEqual(algorithm.calculateMoveForDeletedIndexes([0, 2], numberOfItems: 3), [1: 0])
    // Removing the last index means that the rest of the items are unaffected and should not be moved.
    XCTAssertEqual(algorithm.calculateMoveForDeletedIndexes([0, 1, 2], numberOfItems: 3), [:])
    // Removing the last index means that the rest of the items are unaffected and should not be moved.
    XCTAssertEqual(algorithm.calculateMoveForDeletedIndexes([3, 4, 5], numberOfItems: 6), [:])
    // Removing items in the beginning of the collection means that the items located after the last delete index
    // should relocate to new positions.
    XCTAssertEqual(algorithm.calculateMoveForDeletedIndexes([0, 1, 2], numberOfItems: 6), [5: 2, 4: 1, 3: 0])
  }

}
