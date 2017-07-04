import Foundation

#if os(OSX)
  import Cocoa
#else
  import CoreGraphics
#endif

/// A registry that is used internally when resolving kind to the corresponding component.
public struct Registry {

  public enum Item {
    case classType(View.Type)
    case nib(Nib)
  }

  /// A Key-value dictionary of registred types
  var storage = [String: Item]()

  /// The default item for the registry
  var defaultItem: Item? {
    didSet {
      storage[defaultIdentifier] = defaultItem
    }
  }

  /// A composite item
  var composite: Item? {
    didSet {
      storage[CompositeComponent.identifier] = composite
    }
  }

  /// The default identifier for the registry
  var defaultIdentifier: String {
    guard defaultItem != nil else {
      return ""
    }
    return "default"
  }

  /// A subscripting method for getting a value from storage using a StringConvertible key
  ///
  /// - parameter key: A StringConvertable identifier
  ///
  /// - returns: An optional Nib
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
  func make(_ identifier: String, parentFrame: CGRect = CGRect.zero, useCache: Bool = false) -> (type: RegistryType?, view: View?)? {
    guard let item = storage[identifier] else { return nil }

    let registryType: RegistryType
    var view: View? = nil

    switch item {
    case .classType(let classType):
      registryType = .regular

      if useCache {
        let cacheIdentifier: String = "\(registryType.rawValue)-\(identifier)"
        if let view = cache.object(forKey: cacheIdentifier as NSString) {
          (view as? ItemConfigurable)?.prepareForReuse()
          return (type: registryType, view: view)
        }
      }

      view = classType.init(frame: parentFrame)
    case .nib(let nib):
      registryType = .nib
      let cacheIdentifier: String = "\(registryType.rawValue)-\(identifier)"
      if let view = cache.object(forKey: cacheIdentifier as NSString) {
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

    if let view = view, useCache {
      let cacheIdentifier: String = "\(registryType.rawValue)-\(identifier)"
      cache.setObject(view, forKey: cacheIdentifier as NSString)
    }

    return (type: registryType, view: view)
  }

  /// Construct a view from an `Item`.
  ///
  /// - Parameters:
  ///   - item: An `Item` struct used to create the view.
  ///   - frame: The frame that should be applied to the view.
  /// - Returns: An optional view created based of the `Item`.
  public func makeView<T: View>(from item: Spots.Item, with frame: CGRect) -> T? {
    let view = make(item.kind)?.view as? T
    (view as? ItemConfigurable)?.configure(with: item)
    view?.frame = frame
    return view
  }
}
