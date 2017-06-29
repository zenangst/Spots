import Foundation

/// MoveAlgorithm returns a dictionary with results.
/// The key for each value represents the previous index the the value represents the new index.
class MoveAlgorithm {

  /// Calculate dictionary containing from and to indexes for the affected entries.
  ///
  /// - Parameters:
  ///   - indexes: The indexes that should be inserted from the collection.
  ///   - numberOfItems: The total number of entries in the collection.
  /// - Returns: A dictionary where key represent the old index and the value the new index.
  func calculateMoveForInsertedIndexes(_ indexes: [Int], numberOfItems: Int) -> [Int: Int] {
    let indexes = indexes.sorted(by: { $0 < $1 })
    var result = [Int: Int]()

    guard let startIndex = indexes.first else {
      return [:]
    }

    var offset: Int = startIndex

    for index in startIndex..<numberOfItems {
      repeat {
        offset += 1
      } while indexes.contains(offset)

      result[index] = offset
    }

    return result
  }

  /// Calculate dictionary containing from and to indexes for the remaining entries in a list.
  ///
  /// - Parameters:
  ///   - indexes: The indexes that should be deleted from the collection.
  ///   - numberOfItems: The total number of entries in the collection.
  /// - Returns: A dictionary where key represent the old index and the value the new index.
  func calculateMoveForDeletedIndexes(_ indexes: [Int], numberOfItems: Int) -> [Int: Int] {
    let indexes = indexes.sorted(by: { $0 < $1 })
    var result = [Int: Int]()
    var offset: Int = -1
    var numberOfOffsets = 0

    for index in 0..<numberOfItems {
      if indexes.contains(index) {
        if offset == -1 {
          offset = index
        }
        numberOfOffsets += 1
        continue
      }

      if numberOfOffsets > 0 {
        result[offset + numberOfOffsets] = offset
        offset += 1
      }
    }

    return result
  }
}
