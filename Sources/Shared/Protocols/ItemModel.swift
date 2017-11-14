import Foundation

public protocol ItemCodable: Codable {
  func equal(to rhs: ItemCodable) -> Bool
}
public protocol ItemModel: ItemCodable, Equatable {}

public extension ItemCodable where Self: Equatable {
  func equal(to rhs: ItemCodable) -> Bool {
    guard let rhs = rhs as? Self else {
      return false
    }
    return self == rhs
  }
}

extension ItemCodable {
  func serialize() -> Data? {
    let encoder = JSONEncoder()
    let data = try? encoder.encode(self)
    return data
  }
}
