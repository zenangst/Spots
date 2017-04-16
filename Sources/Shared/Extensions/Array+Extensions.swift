public extension Array where Element : Indexable {

  /// Refresh indexes inside of an array that is indexable.
  mutating func refreshIndexes() {
    enumerated().forEach {
      self[$0.offset].index = $0.offset
    }
  }
}
