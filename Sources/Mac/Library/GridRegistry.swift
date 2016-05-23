import Cocoa
import Brick

/// A view registry that is used internally when resolving kind to the corresponding spot.
public struct GridRegistry {
  /// A Key-value dictionary of registred types
  var storage = [String : NSCollectionViewItem.Type]()

  /**
   A subscripting method for getting a value from storage using a StringConvertible key

   - Returns: An optional UIView type
   */
  public subscript(key: StringConvertible) -> NSCollectionViewItem.Type? {
    get {
      return storage[key.string]
    }
    set(value) {
      storage[key.string] = value
    }
  }
}
