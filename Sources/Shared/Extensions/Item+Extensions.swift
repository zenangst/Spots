extension Array where Element == Item {
  func refreshIndexes() -> [Item] {
    var items = self
    for (index, _) in items.enumerated() {
      items[index].index = index
    }
    return items
  }
}
