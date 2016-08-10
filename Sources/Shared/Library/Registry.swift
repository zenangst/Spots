import Foundation
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

  // MARK: - Template

  private var cache: NSCache = NSCache()

  func purge() {
    cache.removeAllObjects()
  }

  func make(identifier: String) -> View? {
    guard let item = storage[identifier] else { return nil }

    if let view = cache.objectForKey(identifier) as? View {
      return view
    }

    let view: View?

    switch item {
    case .classType(let classType):
      view = classType.init()
    case .nib(let nib):
      view = nib.instantiateWithOwner(nil, options: nil).first as? View
    }

    if let view = view {
      cache.setObject(view, forKey: identifier)
    }

    return view
  }
}

extension Registry: Then {}
