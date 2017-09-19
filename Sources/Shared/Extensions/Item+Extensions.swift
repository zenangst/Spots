extension Array where Element == Item {
  func refreshIndexes() -> [Item] {
    var items = self
    for element in items.indices {
      items[element].index = element
    }
    return items
  }
}
