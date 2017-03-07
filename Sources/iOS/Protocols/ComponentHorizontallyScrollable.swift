import UIKit

public protocol ComponentHorizontallyScrollable: CoreComponent {

  var carouselScrollDelegate: CarouselScrollDelegate? { get set }
  var pageControl: UIPageControl { get }
}
