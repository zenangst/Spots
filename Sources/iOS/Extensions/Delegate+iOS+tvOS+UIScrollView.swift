import UIKit

/// A scroll view extension on CarouselComponent to handle scrolling specifically for this object.
extension Delegate: UIScrollViewDelegate {
  func getCenterIndexPath(in collectionView: UICollectionView, scrollView: UIScrollView, point: CGPoint, contentSize: CGSize, offset: CGFloat) -> IndexPath? {
    guard point.x > 0.0 else {
      return IndexPath(item: 0, section: 0)
    }

    let pointXUpperBound = round(contentSize.width - scrollView.frame.width / 2)
    var point = point
    point.x += scrollView.frame.width / 2
    point.y = scrollView.contentSize.height / 2
    var indexPath: IndexPath?

    while indexPath == nil && point.x < pointXUpperBound {
      indexPath = collectionView.indexPathForItem(at: point)
      point.x += max(offset, 1)
    }

    guard let centerIndexPath = indexPath else {
      return nil
    }

    return centerIndexPath
  }
}
