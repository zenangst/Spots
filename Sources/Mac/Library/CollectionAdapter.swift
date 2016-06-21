import Cocoa

/**
 The CollectionAdapter works as a proxy handler for all Gridable object
 */
public class CollectionAdapter: NSObject {
  // An unowned Listable object
  var spot: Gridable

  /**
   Initialization a new instance of a ListAdapter using a Gridable object

   - Parameter gridable: A Listable object
   */
  init(spot: Gridable) {
    self.spot = spot
  }
}

extension CollectionAdapter : NSCollectionViewDelegate { }

extension CollectionAdapter: NSCollectionViewDataSource {

  public func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
    return 1
  }

  public func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return spot.component.items.count
  }

  public func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
    let reuseIdentifier = spot.reuseIdentifierForItem(indexPath.item)
    let item = collectionView.makeItemWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
    let view = spot.dynamicType.grids[reuseIdentifier]

    if let collectionItem = view?.init() {
      (collectionItem as? SpotConfigurable)?.configure(&spot.component.items[indexPath.item])
      return collectionItem
    } else {
      return item
    }
  }
}

extension CollectionAdapter: NSCollectionViewDelegateFlowLayout {

  @available(OSX 10.11, *)
  public func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> NSSize {
    return spot.sizeForItemAt(indexPath)
  }
}
