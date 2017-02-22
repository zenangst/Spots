import UIKit

public protocol SpotHorizontallyScrollable: Spotable {

  var carouselScrollDelegate: CarouselScrollDelegate? { get set }
  var pageControl: UIPageControl { get }
}
