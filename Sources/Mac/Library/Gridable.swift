import Cocoa

/// Gridable is protocol for Spots that are based on UICollectionView
public protocol Gridable: Spotable {
  // The layout object used to initialize the collection spot controller.
  @available(OSX 10.11, *)
  var layout: NSCollectionViewFlowLayout { get }
  /// The collection view object managed by this gridable object.
  var collectionView: CollectionView { get }
  
  static var grids: GridRegistry { get }

  /**
   Asks the data source for the size of an item in a particular location.

   - Parameter indexPath: The index path of the
   - Returns: Size of the object at index path as CGSize
   */
  func sizeForItemAt(indexPath: NSIndexPath) -> CGSize
}

extension Gridable {
  /**
   Asks the data source for the size of an item in a particular location.

   - Parameter indexPath: The index path of the
   - Returns: Size of the object at index path as CGSize
   */
  public func sizeForItemAt(indexPath: NSIndexPath) -> CGSize {
    if component.span > 0 {
      if #available(OSX 10.11, *) {
        component.items[indexPath.item].size.width = collectionView.frame.width / CGFloat(component.span) - layout.minimumInteritemSpacing
      } else {
        // Fallback on earlier versions
      }
    }

    var width = collectionView.frame.width
    if #available(OSX 10.11, *) {
      width = item(indexPath).size.width - layout.sectionInset.left - layout.sectionInset.right
    }

    NSLog("width: \(width)")

    // Never return a negative width
    guard width > -1 else { return CGSizeZero }

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