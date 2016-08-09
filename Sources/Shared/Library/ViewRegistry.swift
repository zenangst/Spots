import Brick
import Sugar

/// A view registry that is used internally when resolving kind to the corresponding spot.
public class ViewRegistry {
  /// A Key-value dictionary of registred types
  var storage = [String : View.Type]()

  /// Default view type
  public var defaultView: View.Type?

  /**
   A subscripting method for getting a value from storage using a StringConvertible key

   - Returns: An optional UIView type
 */
  public subscript(key: StringConvertible) -> View.Type? {
    get {
      return storage[key.string] ?? storage[String(defaultView)]
    }
    set(value) {
      storage[key.string] = value
    }
  }
}

extension ViewRegistry: Then {}
