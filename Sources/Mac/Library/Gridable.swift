import Cocoa
import Brick

/// Gridable is protocol for Spots that are based on UICollectionView
public protocol Gridable: Spotable {
  // The layout object used to initialize the collection spot controller.
  var layout: NSCollectionViewFlowLayout { get }
  /// The collection view object managed by this gridable object.
  var collectionView: CollectionView { get }

  static var grids: GridRegistry { get }
}

extension Gridable {

  public func prepare() {
    registerAndPrepare { (classType, withIdentifier) in
      collectionView.registerClass(classType, forItemWithIdentifier: withIdentifier)
    }

    var cached: NSView?
    for (index, item) in component.items.enumerate() {
      cachedViewFor(item, cache: &cached)

      if component.span > 0 {
        component.items[index].size.width = collectionView.frame.width / CGFloat(component.span)
      }
      (cached as? SpotConfigurable)?.configure(&component.items[index])
    }
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

    var cached: RegularView?
    component.items.enumerate().forEach { (index: Int, item: ViewModel) in
      prepareItem(item, index: index, cached: &cached)
    }
    cached = nil
  }

  /**
   - Returns: A CGFloat of the total height of all items inside of a component
   */
  public func spotHeight() -> CGFloat {
    return component.items.first?.size.height ?? 0.0
  }

  /**
   Asks the data source for the size of an item in a particular location.

   - Parameter indexPath: The index path of the
   - Returns: Size of the object at index path as CGSize
   */
  public func sizeForItemAt(indexPath: NSIndexPath) -> CGSize {
    if component.span > 0 {
      component.items[indexPath.item].size.width = collectionView.frame.width / CGFloat(component.span)
    }

    let width = item(indexPath).size.width

    // Never return a negative width
    guard width > -1 else { return CGSize.zero }

    return CGSize(
      width: floor(width),
      height: ceil(item(indexPath).size.height))
  }

  func reuseIdentifierForItem(index: Int) -> String {
    let viewModel = item(index)
    if self.dynamicType.grids.storage[viewModel.kind] != nil {
      return viewModel.kind
    } else if self.dynamicType.grids.storage[component.kind] != nil {
      return component.kind
    } else {
      return self.dynamicType.defaultKind.string
    }
  }
}
