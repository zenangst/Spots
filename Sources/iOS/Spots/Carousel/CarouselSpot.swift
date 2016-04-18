import UIKit
import Sugar
import Brick

public class CarouselSpot: NSObject, Gridable {

  public static var views = ViewRegistry()
  public static var configure: ((view: UICollectionView) -> Void)?
  public static var defaultView: UIView.Type = CarouselSpotCell.self
  public static var defaultKind = "carousel"

  public var cachedViews = [String : SpotConfigurable]()
  public var component: Component
  public var index = 0
  public var paginate = false
  public var configure: (SpotConfigurable -> Void)?

  public weak var carouselScrollDelegate: SpotsCarouselScrollDelegate?
  public weak var spotsDelegate: SpotsDelegate?

  public lazy var adapter: CollectionAdapter = CollectionAdapter(spot: self)

  public lazy var layout = UICollectionViewFlowLayout().then {
    $0.scrollDirection = .Horizontal
  }

  public lazy var collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.layout).then {
    $0.backgroundColor = UIColor.whiteColor()
    $0.dataSource = self.adapter
    $0.delegate = self.adapter
    $0.showsHorizontalScrollIndicator = false
  }

  public required init(component: Component) {
    self.component = component
    super.init()
  }

  public convenience init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = UIEdgeInsetsMake(top, left, bottom, right)
    layout.minimumInteritemSpacing = itemSpacing
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

    CarouselSpot.configure?(view: collectionView)
  }
}

extension CarouselSpot: UIScrollViewDelegate {

  public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    guard paginate else { return }

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

    targetContentOffset.memory.x = currentOffset;
    scrollView.setContentOffset(CGPoint(x: newTargetOffset, y:0), animated: true)

    let index: Int = Int(floor(newTargetOffset * CGFloat(items.count) / scrollView.contentSize.width))
    if index >= 0 && index <= items.count {
      carouselScrollDelegate?.spotDidEndScrolling(self, item: items[index])
    }
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
    component.items[indexPath.item].size.width = component.span > 0
      ? collectionView.width / CGFloat(component.span)
      : collectionView.width

    component.items[indexPath.item].size.width -= layout.sectionInset.left

    return CGSize(
      width: ceil(item(indexPath).size.width),
      height: ceil(item(indexPath).size.height))
  }
}
