import UIKit

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

  public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    (spot as? CarouselSpot)?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
  }

  /**
   Tells the delegate when the user scrolls the content view within the receiver.

   - Parameter scrollView: The scroll-view object in which the scrolling occurred.
   */
  public func scrollViewDidScroll(scrollView: UIScrollView) {
    (spot as? CarouselSpot)?.scrollViewDidScroll(scrollView)
  }
}
