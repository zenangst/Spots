import UIKit
import Sugar

public class CarouselSpot: NSObject, Spotable, Gridable {

  public static var views = [String: UIView.Type]()
  public static var configure: ((view: UICollectionView) -> Void)?
  public static var defaultView: UIView.Type = CarouselSpotCell.self

  public var cachedViews = [String : ViewConfigurable]()
  public var component: Component
  public var index = 0
  public var paginate = false

  public weak var carouselScrollDelegate: SpotsCarouselScrollDelegate?
  public weak var spotsDelegate: SpotsDelegate?

  public lazy var layout = UICollectionViewFlowLayout().then {
    $0.scrollDirection = .Horizontal
  }

  public lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.layout)
    collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.showsHorizontalScrollIndicator = false

    return collectionView
    }()

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

extension CarouselSpot: UICollectionViewDelegateFlowLayout {

  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    component.items[indexPath.item].size.width = component.span > 0
      ? collectionView.width / CGFloat(component.span)
      : collectionView.width

    component.items[indexPath.item].size.width -= layout.sectionInset.left

    return CGSize(
      width: ceil(item(indexPath).size.width),
      height: ceil(item(indexPath).size.height))
  }
}

extension CarouselSpot: UICollectionViewDelegate {

  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    spotsDelegate?.spotDidSelectItem(self, item: item(indexPath))
  }
}

extension CarouselSpot: UICollectionViewDataSource {

  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return component.items.count
  }

  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    component.items[indexPath.item].index = indexPath.item

    let reuseIdentifier = item(indexPath).kind.isPresent ? item(indexPath).kind : component.kind
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath).then { $0.optimize() }

    (cell as? ViewConfigurable)?.configure(&component.items[indexPath.item])
    collectionView.collectionViewLayout.invalidateLayout()

    return cell
  }
}
