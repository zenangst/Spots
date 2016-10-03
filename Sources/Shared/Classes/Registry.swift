import Foundation
import Brick

#if os(OSX)
import Cocoa
#endif

public enum RegistryType: String {
  case nib = "nib"
  case regular = "regular"
}

/// A registry that is used internally when resolving kind to the corresponding spot.
open class Registry {

  public enum Item {
    case classType(View.Type)
    case nib(Nib)
  }

  /// A Key-value dictionary of registred types
  var storage = [String : Item]()

  /// The default item for the registry
  var defaultItem: Item? {
    didSet {
      storage[defaultIdentifier] = defaultItem
    }
  }

  var composite: Item? {
    didSet {
      storage["composite"] = composite
    }
  }

  /// The default identifier for the registry
  var defaultIdentifier: String {
    return String(describing: defaultItem)
  }

  /**
   A subscripting method for getting a value from storage using a StringConvertible key

   - returns: An optional Nib
   */
  open subscript(key: StringConvertible) -> Item? {
    get {
      return storage[key.string]
    }
    set(value) {
      storage[key.string] = value
    }
  }

  // MARK: - Template

  /// A cache that stores instances of created views
  fileprivate var cache: NSCache = NSCache<NSString, View>()

  /**
   Empty the current view cache
   */
  func purge() {
    cache.removeAllObjects()
  }

  /**
   Create a view for corresponding identifier

   - parameter identifier: A reusable identifier for the view
   - returns: A tuple with an optional registry type and view
   */
  func make(_ identifier: String) -> (type: RegistryType?, view: View?)? {
    guard let item = storage[identifier] else { return nil }

    let registryType: RegistryType
    var view: View? = nil

    switch item {
    case .classType(let classType):
      registryType = .regular
      if let view = cache.object(forKey: "\(registryType.rawValue)\(identifier)" as NSString) {
        return (type: registryType, view: view)
      }

      view = classType.init()

    case .nib(let nib):
      registryType = .nib
      if let view = cache.object(forKey: "\(registryType.rawValue)\(identifier)" as NSString) {
        return (type: registryType, view: view)
      }
      #if os(OSX)
        var views: NSArray?
        if nib.instantiate(withOwner: nil, topLevelObjects: &views!) {
          view = views?.filter({ $0 is NSTableRowView }).first as? View
        }
      #else
      view = nib.instantiate(withOwner: nil, options: nil).first as? View
      #endif
    }

    if let view = view {
      cache.setObject(view, forKey: "\(registryType.rawValue)\(identifier)" as NSString)
    }

    return (type: registryType, view: view)
  }
}
