import UIKit

/**
 The CollectionAdapter works as a proxy handler for all Gridable object
 */
public class CollectionAdapter: NSObject {
  // An unowned Gridable object
  unowned var spot: Gridable

  /**
   Initialization a new instance of a CollectionAdapter using a Gridable object

   - Parameter gridable: A Gridable object
   */
  init(spot: Gridable) {
    self.spot = spot
  }
}

/**
 A UIScrollViewDelegate extension on CollectionAdapter
 */
extension CollectionAdapter : UIScrollViewDelegate {

  /**
   Tells the delegate when the user finishes scrolling the content.

   - Parameter scrollView: The scroll-view object where the user ended the touch.
   - Parameter velocity: The velocity of the scroll view (in points) at the moment the touch was released.
   - Parameter targetContentOffset: The expected offset when the scrolling action decelerates to a stop
   */
  public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    (spot as? CarouselSpot)?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
  }

  public func scrollViewDidScroll(scrollView: UIScrollView) {
    (spot as? CarouselSpot)?.scrollViewDidScroll(scrollView)
  }
}

extension CollectionAdapter : UICollectionViewDelegate {

  /**
   Asks the delegate for the size of the specified item’s cell.

   - Parameter collectionView: The collection view object displaying the flow layout.
   - Parameter collectionViewLayout: The layout object requesting the information.
   - Parameter indexPath: The index path of the item.
   - Returns: The width and height of the specified item. Both values must be greater than 0.
   */
  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return spot.sizeForItemAt(indexPath)
  }

  /**
   Tells the delegate that the item at the specified index path was selected.

   - Parameter collectionView: The collection view object that is notifying you of the selection change.
   - Parameter indexPath: The index path of the cell that was selected.
   */
  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    spot.spotsDelegate?.spotDidSelectItem(spot, item: spot.item(indexPath))
  }

  public func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }

  @available(iOS 9.0, *)
  public func collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool {
    guard let indexPaths = collectionView.indexPathsForSelectedItems() else { return true }
    return indexPaths.isEmpty
  }

  /**
   Asks the delegate if the specified item should be selected.

   - Parameter collectionView: The collection view object that is asking whether the selection should change.
   - Parameter indexPath: The index path of the cell to be selected.
   - Returns: true if the item should be selected or false if it should not.
   */
  public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    if let indexPath = collectionView.indexPathsForSelectedItems()?.first {
      collectionView.deselectItemAtIndexPath(indexPath, animated: true)
      return false
    } else {
      return true
    }
  }
}

extension CollectionAdapter : UICollectionViewDataSource {

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

    let reuseIdentifier = spot.reuseIdentifierForItem(indexPath)
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)

    #if os(iOS)
      cell.optimize()
    #endif

    if let cell = cell as? SpotConfigurable {
      cell.configure(&spot.component.items[indexPath.item])
      if spot.component.items[indexPath.item].size.height == 0.0 {
        spot.component.items[indexPath.item].size = cell.size
      }

      spot.configure?(cell)
    }

    collectionView.collectionViewLayout.invalidateLayout()

    return cell
  }
}

extension CollectionAdapter: UICollectionViewDelegateFlowLayout {

  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    guard spot.layout.scrollDirection == .Horizontal else { return spot.layout.sectionInset.bottom }

    return spot.layout.minimumLineSpacing
  }

  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    guard spot.layout.scrollDirection == .Horizontal else { return spot.layout.sectionInset }

    let left = spot.layout.minimumLineSpacing / 2
    let right = spot.layout.minimumLineSpacing / 2

    return UIEdgeInsets(top: spot.layout.sectionInset.top,
                        left: left,
                        bottom: spot.layout.sectionInset.bottom,
                        right: right)
  }
}
