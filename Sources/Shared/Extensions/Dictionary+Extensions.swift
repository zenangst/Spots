import Tailor

/**
 A dictionary extension to work with custom Key type
 */
public extension Dictionary where Key: ExpressibleByStringLiteral {

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
      guard let key = key.string as? Key else {
        return
      }
      self[key] = value
    }
    get {
      guard let key = key.string as? Key else {
        return nil
      }
      return self[key]
    }
  }
}
