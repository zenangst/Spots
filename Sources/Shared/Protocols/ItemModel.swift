import Tailor

public protocol ItemModel: ItemCodable, Equatable {}
public protocol ItemCodable: Codable {}

public func == (lhs: ItemCodable, rhs: ItemCodable) -> Bool {
  guard type(of: lhs) == type(of: rhs) else {
    return false
  }

  return String(describing: lhs).hashValue == String(describing: rhs).hashValue
}

extension ItemModel {
  public var dictionary: [String : Any] {
    var properties = [String: Any]()

    for tuple in Mirror(reflecting: self).children {
      guard let key = tuple.label else { continue }

      if let value = Mirror(reflecting: tuple.value).descendant("Some") {
        properties[key] = value
      } else {
        properties[key] = tuple.value
      }
    }

    return properties
  }
}
