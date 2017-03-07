import UIKit

public protocol SpotHorizontallyScrollable: CoreComponent {

  var carouselScrollDelegate: CarouselScrollDelegate? { get set }
  var pageControl: UIPageControl { get }
}
