import Tailor

// MARK: - Array

public extension Array where Element : Indexable {

  mutating func refreshIndexes() {
    enumerated().forEach {
      self[$0.offset].index = $0.offset
    }
  }
}

// MARK: - Dictionary

/**
 A dictionary extension to work with custom Key type
 */
extension Dictionary where Key: ExpressibleByStringLiteral {

  /**
   - parameter name: The name of the property that you want to map

   - returns: A generic type if casting succeeds, otherwise it returns nil
   */
  func property<T>(_ name: Item.Key) -> T? {
    return property(name.string)
  }

  /**
   Access the value associated with the given key.

   - parameter key: The key associated with the value you want to get

   - returns: The value associated with the given key
   */
  subscript(key: Item.Key) -> Value? {
    set(value) {
      guard let key = key.string as? Key else { return }
      self[key] = value
    }
    get {
      guard let key = key.string as? Key else { return nil }
      return self[key]
    }
  }
}

// MARK: - Mappable

extension Mappable {

  /**
   - returns: A key-value dictionary.
   */
  var metaProperties: [String : Any] {
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
