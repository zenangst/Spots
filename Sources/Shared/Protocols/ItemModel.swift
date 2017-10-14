import Tailor

public protocol ItemModel: ItemCodable, Equatable {}
public protocol ItemCodable: Codable {}

public func == (lhs: ItemCodable, rhs: ItemCodable) -> Bool {
  guard type(of: lhs) == type(of: rhs) else {
    return false
  }

  return String(describing: lhs).hashValue == String(describing: rhs).hashValue
}
