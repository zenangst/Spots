import Tailor

/**
 A dictinary extension to work with custom Key type
 */
extension Dictionary where Key: StringLiteralConvertible {

  /**
   - parameter name: The name of the property that you want to map
   - returns: A generic type if casting succeeds, otherwise it returns nil
   */
  func property<T>(name: Component.Key) -> T? {
    return property(name.string)
  }

  /**
   - parameter name: The name of the property that you want to map
   - returns: A mappable object array, otherwise it returns nil
   */
  func relations<T: Mappable>(name: Component.Key) -> [T]? {
    return relations(name.string)
  }

  /**
   Access the value associated with the given key.
   - parameter key: The key associated with the value you want to get
   - returns: The value associated with the given key
   */
  subscript(key: Component.Key) -> Value? {
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
