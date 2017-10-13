import Tailor

public protocol ItemModel {
  var identifier: String { get }
}

public extension ItemModel {
  func equal(to rhs: ItemModel) -> Bool {
    guard type(of: self) == type(of: rhs) else {
      return false
    }

    return identifier == rhs.identifier
  }
}

public extension ItemModel where Self : Equatable {
  func equal(to rhs: Self) -> Bool {
    return self == rhs
  }
}
