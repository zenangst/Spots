import UIKit

/**
 A UIScrollViewDelegate extension on CollectionAdapter
 */
extension CollectionAdapter : UIScrollViewDelegate {

  /**
   Tells the delegate when the user finishes scrolling the content.

   - parameter scrollView: The scroll-view object where the user ended the touch.
   - parameter velocity: The velocity of the scroll view (in points) at the moment the touch was released.
   - parameter targetContentOffset: The expected offset when the scrolling action decelerates to a stop
   */
  public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    (spot as? CarouselSpot)?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
  }

  #if os(iOS)
  /**
   Tells the delegate when dragging ended in the scroll view.

   - parameter scrollView: The scroll-view object that finished scrolling the content view.
   - parameter decelerate: true if the scrolling movement will continue, but decelerate, after a touch-up gesture during a dragging operation.
   */
  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    (spot as? CarouselSpot)?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
  }
  #endif

  /**
   Tells the delegate when the user scrolls the content view within the receiver.

   - parameter scrollView: The scroll-view object in which the scrolling occurred.
   */
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // This is a weird workaround to get the carousel to scroll more smoothly... weird I know.
    let _ = spot.layout.layoutAttributesForElements(in: scrollView.frame)
    (spot as? CarouselSpot)?.scrollViewDidScroll(scrollView)
  }
}
