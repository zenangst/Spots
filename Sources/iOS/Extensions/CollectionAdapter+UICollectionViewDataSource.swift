import UIKit

extension CollectionAdapter : UICollectionViewDataSource {

  public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let header = spot.component.header.isEmpty
      ? spot.dynamicType.headers.defaultIdentifier
      : spot.component.header

    let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: header, forIndexPath: indexPath)
    (view as? Componentable)?.configure(spot.component)

    return view
  }

  /**
   Asks the data source for the number of items in the specified section. (required)

   - Parameter collectionView: An object representing the collection view requesting this information.
   - Parameter section: An index number identifying a section in collectionView. This index value is 0-based.
   - Returns: The number of rows in section.
   */
  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return spot.component.items.count
  }

  /**
   Asks the data source for the cell that corresponds to the specified item in the collection view. (required)

   - Parameter collectionView: An object representing the collection view requesting this information.
   - Parameter indexPath: The index path that specifies the location of the item.
   - Returns: A configured cell object. You must not return nil from this method.
   */
  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    spot.component.items[indexPath.item].index = indexPath.item

    let reuseIdentifier = spot.identifier(indexPath)
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)

    #if os(iOS)
      cell.optimize()
    #endif

    if let composite = cell as? SpotComposable {
      let spots = spot.spotsCompositeDelegate?.resolve(spotIndex: spot.index, itemIndex: indexPath.item)
      composite.configure(&spot.component.items[indexPath.item], spots: spots)
    } else if let cell = cell as? SpotConfigurable {
      cell.configure(&spot.component.items[indexPath.item])
      if spot.component.items[indexPath.item].size.height == 0.0 {
        spot.component.items[indexPath.item].size = cell.size
      }
      spot.configure?(cell)
    }

    return cell
  }
}
