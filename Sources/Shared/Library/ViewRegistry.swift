import Brick

/// A view registry that is used internally when resolving kind to the corresponding spot.
public struct ViewRegistry {
  /// A Key-value dictionary of registred types
  var storage = [String : RegularView.Type]()

  /**
   A subscripting method for getting a value from storage using a StringConvertible key

   - Returns: An optional UIView type
   */
  public subscript(key: StringConvertible) -> RegularView.Type? {
    get {
      return storage[key.string]
    }
    set(value) {
      storage[key.string] = value
    }
  }
}
