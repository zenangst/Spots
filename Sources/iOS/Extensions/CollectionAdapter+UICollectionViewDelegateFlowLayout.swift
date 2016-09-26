import UIKit

extension CollectionAdapter: UICollectionViewDelegateFlowLayout {

  /**
   Asks the delegate for the spacing between successive rows or columns of a section.

   - parameter collectionView:       The collection view object displaying the flow layout.
   - parameter collectionViewLayout: The layout object requesting the information.
   - parameter section:              The index number of the section whose line spacing is needed.
   - returns: The minimum space (measured in points) to apply between successive lines in a section.
   */
  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    guard spot.layout.scrollDirection == .Horizontal else { return spot.layout.sectionInset.bottom }

    return spot.layout.minimumLineSpacing
  }

  /**
   Asks the delegate for the margins to apply to content in the specified section.

   - parameter collectionView:       The collection view object displaying the flow layout.
   - parameter collectionViewLayout: The layout object requesting the information.
   - parameter section:              The index number of the section whose insets are needed.
   - returns: The margins to apply to items in the section.
   */
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
