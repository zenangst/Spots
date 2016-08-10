import Brick
import Sugar

/// A registry that is used internally when resolving kind to the corresponding spot.
public class Registry {

  public enum Item {
    case classType(View.Type)
    case nib(Nib)
  }

  /// A Key-value dictionary of registred types
  var storage = [String : Item]()

  var defaultItem: Item? {
    didSet {
      storage[String(defaultItem)] = defaultItem
    }
  }

  /**
   A subscripting method for getting a value from storage using a StringConvertible key

   - Returns: An optional Nib
   */
  public subscript(key: StringConvertible) -> Item? {
    get {
      return storage[key.string]
    }
    set(value) {
      storage[key.string] = value
    }
  }
}

extension Registry: Then {}
