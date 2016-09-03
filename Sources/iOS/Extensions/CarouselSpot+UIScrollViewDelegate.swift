import UIKit
import Brick

extension CarouselSpot: UIScrollViewDelegate {

  private func paginatedEndScrolling() {
    var currentCellOffset = collectionView.contentOffset
    if paginateByItem {
      currentCellOffset.x += collectionView.width / 2
    } else {
      if pageControl.currentPage == 0 {
        currentCellOffset.x = collectionView.width / 2
      } else {
        currentCellOffset.x = (collectionView.width * CGFloat(pageControl.currentPage)) + collectionView.width / 2
        currentCellOffset.x += layout.sectionInset.left * CGFloat(pageControl.currentPage)
      }
    }

    if let indexPath = collectionView.indexPathForItemAtPoint(currentCellOffset) {
      collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
    } else {
      currentCellOffset.x += layout.sectionInset.left
      if let indexPath = collectionView.indexPathForItemAtPoint(currentCellOffset) {
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
      }
    }
  }

  public func scrollViewDidScroll(scrollView: UIScrollView) {
    carouselScrollDelegate?.spotDidScroll(self)
  }

  public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard paginate else { return }
    paginatedEndScrolling()
  }

  public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    #if os(iOS)
      guard paginate else { return }
    #endif

    let pageWidth: CGFloat = collectionView.width
    let currentOffset = scrollView.contentOffset.x
    let targetOffset = targetContentOffset.memory.x

    var newTargetOffset: CGFloat = targetOffset > currentOffset
      ? ceil(currentOffset / pageWidth) * pageWidth
      : floor(currentOffset / pageWidth) * pageWidth

    if newTargetOffset > scrollView.contentSize.width {
      newTargetOffset = scrollView.contentSize.width
    } else if newTargetOffset < 0 {
      newTargetOffset = 0
    }

    let index: Int = Int(floor(newTargetOffset * CGFloat(items.count) / scrollView.contentSize.width))

    if index >= 0 && index <= items.count {
      carouselScrollDelegate?.spotDidEndScrolling(self, item: items[index])
    }

    let floatIndex = ceil(CGFloat(index) / component.span)

    #if os(iOS)
      pageControl.currentPage = Int(floatIndex)
    #endif

    paginatedEndScrolling()
  }

  public func scrollTo(predicate: (ViewModel) -> Bool) {
    if let index = items.indexOf(predicate) {
      let pageWidth: CGFloat = collectionView.width - layout.sectionInset.right
        + layout.sectionInset.left

      collectionView.setContentOffset(CGPoint(x: pageWidth * CGFloat(index), y:0), animated: true)
    }
  }
}
