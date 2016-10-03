import Foundation
import Brick

#if os(OSX)
import Cocoa
#endif

public enum RegistryType: String {
  case Nib = "nib"
  case Regular = "regular"
}

/// A registry that is used internally when resolving kind to the corresponding spot.
public class Registry {

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
    return String(defaultItem)
  }

  /**
   A subscripting method for getting a value from storage using a StringConvertible key

   - returns: An optional Nib
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

  /// A cache that stores instances of created views
  private var cache: NSCache = NSCache()

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
  func make(identifier: String) -> (type: RegistryType?, view: View?)? {
    guard let item = storage[identifier] else { return nil }

    let registryType: RegistryType?
    var view: View? = nil

    switch item {
    case .classType(let classType):
      registryType = .Regular
      if let view = cache.objectForKey(registryType!.rawValue + identifier) as? View {
        return (type: registryType, view: view)
      }

      view = classType.init()

    case .nib(let nib):
      registryType = .Nib
      if let view = cache.objectForKey(registryType!.rawValue + identifier) as? View {
        return (type: registryType, view: view)
      }
      #if os(OSX)
        var views: NSArray?
        if nib.instantiateWithOwner(nil, topLevelObjects: &views) {
          view = views?.filter({ $0 is NSTableRowView }).first as? View
        }
      #else
      view = nib.instantiateWithOwner(nil, options: nil).first as? View
      #endif
    }

    if let view = view {
      cache.setObject(view, forKey: registryType!.rawValue + identifier)
    }

    return (type: registryType, view: view)
  }
}
