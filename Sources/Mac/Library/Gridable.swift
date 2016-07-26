import Cocoa
import Brick

/// Gridable is protocol for Spots that are based on UICollectionView
public protocol Gridable: Spotable {
  // The layout object used to initialize the collection spot controller.
  var layout: NSCollectionViewLayout { get }
  /// The collection view object managed by this gridable object.
  var collectionView: CollectionView { get }

  static var grids: GridRegistry { get }
  static var defaultGrid: NSCollectionViewItem.Type { get }
}

public struct GridableMeta {
  public struct Key {
    public static let sectionInsetTop = "insetTop"
    public static let sectionInsetLeft = "insetLeft"
    public static let sectionInsetRight = "insetRight"
    public static let sectionInsetBottom = "insetBottom"
  }
}

extension Gridable {

  public func prepare() {
    registerAndPrepare { (classType, withIdentifier) in
      collectionView.registerClass(classType, forItemWithIdentifier: withIdentifier)
    }

    var cached: NSCollectionViewItem?
    for (index, item) in component.items.enumerate() {
      cachedGridFor(item, cache: &cached)

      if let layout = layout as? NSCollectionViewFlowLayout where component.span > 0 {
        component.items[index].size.width = collectionView.frame.width / CGFloat(component.span) - layout.sectionInset.left - layout.sectionInset.right
      }

      if let configurable = cached as? SpotConfigurable {
        configurable.configure(&component.items[index])
      }
    }
  }

  func cachedGridFor(item: ViewModel, inout cache: NSCollectionViewItem?) {
    let reuseIdentifer = item.kind.isPresent ? item.kind : component.kind
    let componentClass = self.dynamicType.grids.storage[reuseIdentifer] ?? self.dynamicType.defaultGrid

    if cache?.isKindOfClass(componentClass) == false { cache = nil }
    if cache == nil { cache = componentClass.init() }
  }

  /**
   - Parameter spot: Spotable
   - Parameter register: A closure containing class type and reuse identifer
   */
  func registerAndPrepare(@noescape register: (classType: NSCollectionViewItem.Type, withIdentifier: String) -> Void) {
    if component.kind.isEmpty { component.kind = Self.defaultKind.string }

    Self.grids.storage.forEach { (reuseIdentifier: String, classType: NSCollectionViewItem.Type) in
      register(classType: classType, withIdentifier: reuseIdentifier)
    }

//    if !Self.grids.storage.keys.contains(component.kind) {
//      register(classType: Self.defaultView, withIdentifier: component.kind)
//    }

    var cached: NSCollectionViewItem?
    component.items.enumerate().forEach { (index: Int, item: ViewModel) in
      prepareItem(item, index: index, cached: &cached)
    }
    cached = nil
  }

  /**
   Prepares a view model item before being used by the UI component

   - Parameter item: A view model
   - Parameter index: The index of the view model
   - Parameter cached: An optional UIView, used to reduce the amount of different reusable views that should be prepared.
   */
  public func prepareItem(item: ViewModel, index: Int, inout cached: NSCollectionViewItem?) {
    cachedGridFor(item, cache: &cached)

    component.items[index].index = index

    guard let view = cached as? SpotConfigurable else { return }

    view.configure(&component.items[index])

    if component.items[index].size.height == 0 {
      component.items[index].size.height = layout.collectionViewContentSize.height
    }

    if component.items[index].size.width == 0 {
      component.items[index].size.width = layout.collectionViewContentSize.width
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

  func reuseIdentifierForItem(index: Int) -> String {
    guard let viewModel = item(index) else { return self.dynamicType.defaultKind.string }

    if self.dynamicType.grids.storage[viewModel.kind] != nil {
      return viewModel.kind
    } else if self.dynamicType.grids.storage[component.kind] != nil {
      return component.kind
    } else {
      return self.dynamicType.defaultKind.string
    }
  }

  public func deselect() {
    collectionView.deselectAll(nil)
  }
}
