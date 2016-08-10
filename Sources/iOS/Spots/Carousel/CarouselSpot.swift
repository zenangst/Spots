import UIKit
import Sugar
import Brick

public class CarouselSpot: NSObject, Gridable {

  public static var views = ViewRegistry().then {
    $0.defaultView = CarouselSpotCell.self
  }

  public static var nibs = NibRegistry()
  public static var configure: ((view: UICollectionView, layout: UICollectionViewFlowLayout) -> Void)?

  public private(set) var stateCache: SpotCache?

  public var component: Component {
    willSet(value) {
      #if os(iOS)
      pageControl.numberOfPages = Int(floor(CGFloat(component.items.count) / component.span))
      #endif
    }
  }

  public var index = 0

  #if os(iOS)
  public var paginate = false {
    willSet(newValue) {
      collectionView.pagingEnabled = newValue
    }
  }
  #endif

  public var pageIndicator: Bool = false {
    willSet(value) {
      if value {
        pageControl.currentPage = 1
        pageControl.width = backgroundView.frame.width
        collectionView.backgroundView?.addSubview(pageControl)
      } else {
        pageControl.removeFromSuperview()
      }
    }
  }

  public var configure: (SpotConfigurable -> Void)?

  public weak var carouselScrollDelegate: SpotsCarouselScrollDelegate?
  public weak var spotsDelegate: SpotsDelegate?

  public var adapter: SpotAdapter? {
    return collectionAdapter
  }
  public lazy var collectionAdapter: CollectionAdapter = CollectionAdapter(spot: self)

  public lazy var pageControl = UIPageControl().then {
    $0.frame.size.height = 22
    $0.pageIndicatorTintColor = UIColor.lightGrayColor()
    $0.currentPageIndicatorTintColor = UIColor.grayColor()
  }

  public lazy var layout = UICollectionViewFlowLayout().then {
    $0.scrollDirection = .Horizontal
  }

  public lazy var collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout).then {
    $0.dataSource = self.collectionAdapter
    $0.delegate = self.collectionAdapter
    $0.showsHorizontalScrollIndicator = false
    $0.backgroundView = self.backgroundView
  }

  public lazy var backgroundView = UIView()

  public required init(component: Component) {
    self.component = component
    super.init()
  }

  public convenience init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0, lineSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    layout.minimumInteritemSpacing = itemSpacing
    layout.minimumLineSpacing = lineSpacing
  }

  public convenience init(cacheKey: String) {
    let stateCache = SpotCache(key: cacheKey)

    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache

    registerAndPrepare()
  }

  public func setup(size: CGSize) {
    collectionView.frame.size = size

    if collectionView.contentSize.height > 0 {
      collectionView.height = collectionView.contentSize.height
    } else {
      collectionView.height = component.items.first?.size.height ?? 0

      if collectionView.height > 0 {
        collectionView.height += layout.sectionInset.top + layout.sectionInset.bottom
      }
    }

    #if os(iOS)
    paginate ?= component.meta("paginate", type: Bool.self)
    pageIndicator ?= component.meta("pageIndicator", type: Bool.self)
    #endif

    CarouselSpot.configure?(view: collectionView, layout: layout)

    guard pageIndicator else { return }
    layout.sectionInset.bottom = layout.sectionInset.bottom + pageControl.height
    collectionView.height += layout.sectionInset.top + layout.sectionInset.bottom
    pageControl.frame.origin.y = collectionView.height - pageControl.height
  }
}

extension CarouselSpot: UIScrollViewDelegate {

  public func scrollViewDidScroll(scrollView: UIScrollView) {
    carouselScrollDelegate?.spotDidScroll(self)
  }

  public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    #if os(iOS)
    guard paginate else { return }
    #endif

    let pageWidth: CGFloat = collectionView.width - layout.sectionInset.right
     + layout.sectionInset.left + layout.minimumLineSpacing
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

    #if os(iOS)
    pageControl.currentPage = Int(floor(CGFloat(index) / component.span))
    #endif
  }

  public func scrollTo(predicate: (ViewModel) -> Bool) {
    if let index = items.indexOf(predicate) {
      let pageWidth: CGFloat = collectionView.width - layout.sectionInset.right
        + layout.sectionInset.left + layout.minimumLineSpacing

      collectionView.setContentOffset(CGPoint(x: pageWidth * CGFloat(index), y:0), animated: true)
    }
  }
}

extension CarouselSpot {

  public func sizeForItemAt(indexPath: NSIndexPath) -> CGSize {
    var width = component.span > 0
      ? collectionView.width / CGFloat(component.span)
      : collectionView.width

    width -= layout.sectionInset.left - layout.sectionInset.right
    width -= layout.minimumInteritemSpacing
    width -= layout.minimumLineSpacing
    width -= collectionView.contentInset.left + collectionView.contentInset.right

    component.items[indexPath.item].size.width = width

    return CGSize(
      width: ceil(component.items[indexPath.item].size.width),
      height: ceil(component.items[indexPath.item].size.height))
  }
}
