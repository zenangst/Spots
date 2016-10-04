import UIKit

extension CollectionAdapter : UICollectionViewDataSource {

  /**
   Asks your data source object to provide a supplementary view to display in the collection view.
   A configured supplementary view object. You must not return nil from this method.

   - parameter collectionView: The collection view requesting this information.
   - parameter kind:           The kind of supplementary view to provide. The value of this string is defined by the layout object that supports the supplementary view.
   - parameter indexPath:      The index path that specifies the location of the new supplementary view.

   - returns: A configured supplementary view object.
   */
  public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = spot.component.header.isEmpty
      ? type(of: spot).headers.defaultIdentifier
      : spot.component.header

    let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: header, for: indexPath)
    (view as? Componentable)?.configure(spot.component)

    return view
  }

  /**
   Asks the data source for the number of items in the specified section. (required)

   - parameter collectionView: An object representing the collection view requesting this information.
   - parameter section: An index number identifying a section in collectionView. This index value is 0-based.
   - returns: The number of rows in section.
   */
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return spot.component.items.count
  }

  /**
   Asks the data source for the cell that corresponds to the specified item in the collection view. (required)

   - parameter collectionView: An object representing the collection view requesting this information.
   - parameter indexPath: The index path that specifies the location of the item.
   - returns: A configured cell object. You must not return nil from this method.
   */
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    spot.component.items[indexPath.item].index = indexPath.item

    let reuseIdentifier = spot.identifier(indexPath)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    if let composite = cell as? SpotComposable {
      let spots = spot.spotsCompositeDelegate?.resolve(spot.index, itemIndex: (indexPath as NSIndexPath).item)
      composite.configure(&spot.component.items[indexPath.item], spots: spots)
    } else if let cell = cell as? SpotConfigurable {
      cell.configure(&spot.component.items[indexPath.item])
      if spot.component.items[indexPath.item].size.height == 0.0 {
        spot.component.items[indexPath.item].size = cell.preferredViewSize
      }
      spot.configure?(cell)
    }

    return cell
  }
}
