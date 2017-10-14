import Tailor

public protocol ItemModel {}

public func == (lhs: ItemModel, rhs: ItemModel) -> Bool {
  guard type(of: lhs) == type(of: rhs) else {
    return false
  }

  return String(describing: lhs).hashValue == String(describing: rhs).hashValue
}
