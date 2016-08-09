import Brick
import Sugar

/// A nib registry that is used internally when resolving kind to the corresponding spot.
public class NibRegistry {
  /// A Key-value dictionary of registred types
  var storage = [String : Nib]()

  /**
   A subscripting method for getting a value from storage using a StringConvertible key

   - Returns: An optional Nib
   */
  public subscript(key: StringConvertible) -> Nib? {
    get {
      return storage[key.string]
    }
    set(value) {
      storage[key.string] = value
    }
  }
}

extension NibRegistry: Then {}
