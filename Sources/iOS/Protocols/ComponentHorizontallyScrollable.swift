import UIKit

public protocol ComponentHorizontallyScrollable {

  var carouselScrollDelegate: CarouselScrollDelegate? { get set }
  var pageControl: UIPageControl { get }
  var model: ComponentModel { get }
}
