import Cocoa
import Brick

public struct GridableMeta {
  public struct Key {
    public static let sectionInsetTop = "insetTop"
    public static let sectionInsetLeft = "insetLeft"
    public static let sectionInsetRight = "insetRight"
    public static let sectionInsetBottom = "insetBottom"
  }
}

extension Gridable {

  public var responder: NSResponder {
    return collectionView
  }

  public var nextResponder: NSResponder? {
    get {
      return collectionView.nextResponder
    }
    set {
      collectionView.nextResponder = newValue
    }
  }

  public func prepare() {
    var cached: NSCollectionViewItem?
    for (index, item) in component.items.enumerate() {
      if let layout = layout as? NSCollectionViewFlowLayout where component.span > 0 {
        component.items[index].size.width = collectionView.frame.width / CGFloat(component.span) - layout.sectionInset.left - layout.sectionInset.right
      }

      if let configurable = cached as? SpotConfigurable {
        configurable.configure(&component.items[index])
      }
    }
  }

  // MARK: - Spotable

  public func register() {

    for (identifier, item) in self.dynamicType.grids.storage {
      switch item {
      case .classType(let classType):
          self.collectionView.registerClass(classType, forItemWithIdentifier: identifier)
      default: break
      }
    }
  }

  /**
   - Returns: A CGFloat of the total height of all items inside of a component
   */
  public func spotHeight() -> CGFloat {
    return layout.collectionViewContentSize.height
  }

  /**
   Asks the data source for the size of an item in a particular location.

   - Parameter indexPath: The index path of the
   - Returns: Size of the object at index path as CGSize
   */
  public func sizeForItemAt(indexPath: NSIndexPath) -> CGSize {
    var sectionInsets: CGFloat = 0.0
    if let layout = layout as? NSCollectionViewFlowLayout where component.span > 0 {
      component.items[indexPath.item].size.width = (collectionView.frame.width / CGFloat(component.span)) - layout.sectionInset.left - layout.sectionInset.right
      sectionInsets = layout.sectionInset.left + layout.sectionInset.right
    }

    var width = (item(indexPath)?.size.width ?? 0) - sectionInsets
    let height = item(indexPath)?.size.height ?? 0
    // Never return a negative width
    guard width > -1 else {
      return CGSize.zero
    }

    if width >= collectionView.frame.width {
      width -= 2
    }

    let size = CGSize(
      width: floor(width),
      height: ceil(height))

    return size
  }

  public func identifier(index: Int) -> String {
    guard let item = item(index)
      where self.dynamicType.grids.storage[item.kind] != nil
      else {
        return self.dynamicType.views.defaultIdentifier
    }

    return item.kind
  }

  public func deselect() {
    collectionView.deselectAll(nil)
  }

  public static func register(view view: NSCollectionViewItem.Type, identifier: StringConvertible) {
    self.grids.storage[identifier.string] = GridRegistry.Item.classType(view)
  }

  public static func register(defaultView: NSCollectionViewItem.Type) {
    self.grids.storage[self.grids.defaultIdentifier] = GridRegistry.Item.classType(defaultView)
  }
}
