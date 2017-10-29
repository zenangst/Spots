import Foundation

public protocol ItemCodable: Codable {}
public protocol ItemModel: ItemCodable, Equatable {}

public func == (lhs: ItemCodable, rhs: ItemCodable) -> Bool {
  guard type(of: lhs) == type(of: rhs) else {
    return false
  }

  var lhsOutput = ""
  var rhsOutput = ""
  dump(lhs, to: &lhsOutput)
  dump(rhs, to: &rhsOutput)

  return lhsOutput == rhsOutput
}

extension ItemCodable {
  func serialize() -> Data? {
    let encoder = JSONEncoder()
    let data = try? encoder.encode(self)
    return data
  }
}
