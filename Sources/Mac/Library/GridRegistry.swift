import Cocoa
import Brick

/// A view registry that is used internally when resolving kind to the corresponding spot.
public struct GridRegistry {

  public enum Item {
    case classType(NSCollectionViewItem.Type)
    case nib(Nib)
  }

  /// A Key-value dictionary of registred types
  var storage = [String : Item]()

  var defaultItem: Item? {
    didSet {
      storage[defaultIdentifier] = defaultItem
    }
  }

  var defaultIdentifier: String {
    return String(defaultItem)
  }

  /**
   A subscripting method for getting a value from storage using a StringConvertible key

   - Returns: An optional UIView type
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
