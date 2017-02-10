import Cocoa

/// A view registry that is used internally when resolving kind to the corresponding spot.
public struct GridRegistry {

  public enum Item {
    case classType(NSCollectionViewItem.Type)
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

  /// The default identifier for the registry
  var defaultIdentifier: String {
    return String(describing: defaultItem)
  }

  /// A composite item
  var composite: Item? {
    didSet {
      storage["composite"] = composite
    }
  }

  /**
   A subscripting method for getting a value from storage using a StringConvertible key

   - returns: An optional UIView type
   */
  public subscript(key: StringConvertible) -> Item? {
    get {
      return storage[key.string]
    }
    set(value) {
      storage[key.string] = value
    }
  }

  /**
   Create a view for corresponding identifier

   - parameter identifier: A reusable identifier for the view
   - returns: A tuple with an optional registry type and view
   */
  func make(_ identifier: String) -> (type: RegistryType?, item: NSCollectionViewItem?)? {
    guard let item = storage[identifier] else { return nil }

    let registryType: RegistryType
    var view: NSCollectionViewItem? = nil

    switch item {
    case .classType(let classType):
      registryType = .regular
      view = classType.init()
    case .nib(let nib):
      registryType = .nib
      var views = NSArray()
      if nib.instantiate(withOwner: nil, topLevelObjects: &views) {
        view = views.filter({ $0 is NSCollectionViewItem }).first as? NSCollectionViewItem
      }
    }

    return (type: registryType, item: view)
  }
}
