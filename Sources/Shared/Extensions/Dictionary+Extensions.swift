import Tailor

/**
 A dictionary extension to work with custom Key type
 */
public extension Dictionary where Key: ExpressibleByStringLiteral {

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
