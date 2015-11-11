import UIKit
import GoldenRetriever
import Sugar
import Tailor

public class CarouselSpot: NSObject, Spotable {

  public static var cells = [String: UICollectionViewCell.Type]()
  public var component: Component
  public weak var sizeDelegate: SpotSizeDelegate?
  public weak var spotDelegate: SpotsDelegate?

  public lazy var layout: UICollectionViewFlowLayout = { [unowned self] in
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .Horizontal

    return layout
    }()

  public lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.layout)
    collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.frame.size.width = UIScreen.mainScreen().bounds.width
    collectionView.showsHorizontalScrollIndicator = false

    return collectionView
    }()

  public required init(component: Component) {
    self.component = component
    super.init()

    let items = component.items
    for (index, item) in items.enumerate() {
      let componentCellClass = GridSpot.cells[item.kind] ?? CarouselSpotCell.self
      self.collectionView.registerClass(componentCellClass, forCellWithReuseIdentifier: "CarouselCell\(item.kind.capitalizedString)")

      guard let gridCell = componentCellClass.init() as? Itemble else { return }
      self.component.items[index].size.width = collectionView.frame.width / CGFloat(component.span)
      self.component.items[index].size.height = gridCell.size.height
    }
  }

  public convenience init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0) {
    self.init(component: component)
    
    layout.sectionInset = UIEdgeInsetsMake(top, left, bottom, right)
    layout.minimumInteritemSpacing = itemSpacing
  }

  public func setup() {
    collectionView.backgroundColor = UIColor(hex:
      component.meta.property("background-color") ?? "FFFFFF")
    if collectionView.contentSize.height > 0 {
      collectionView.frame.size.height = collectionView.contentSize.height
    } else {
      collectionView.frame.size.height = component.items.first?.size.height ?? 0
      collectionView.frame.size.height += layout.sectionInset.top + layout.sectionInset.bottom
    }
  }

  public func render() -> UIView {
    return collectionView
  }

  public func layout(size: CGSize) {
    collectionView.collectionViewLayout.invalidateLayout()
    collectionView.frame.size.width = size.width
  }
}

extension CarouselSpot: UIScrollViewDelegate {

  public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let pageWidth: CGFloat = collectionView.frame.width - layout.sectionInset.left + layout.minimumLineSpacing
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
  }
}

extension CarouselSpot: UICollectionViewDelegateFlowLayout {

  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    component.items[indexPath.item].size.width = collectionView.frame.width / CGFloat(component.span)
    component.items[indexPath.item].size.width -= layout.sectionInset.left
    let item = component.items[indexPath.item]

    return CGSize(width: item.size.width, height: item.size.height)
  }
}

extension CarouselSpot: UICollectionViewDelegate {

  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    spotDelegate?.spotDidSelectItem(self, item: component.items[indexPath.item])
  }
}

extension CarouselSpot: UICollectionViewDataSource {

  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return component.items.count
  }

  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    var item = component.items[indexPath.item]
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CarouselCell\(item.kind.capitalizedString)", forIndexPath: indexPath)

    if let grid = cell as? Itemble {
      grid.configure(&item)
      component.items[indexPath.item] = item
      collectionView.collectionViewLayout.invalidateLayout()
      sizeDelegate?.sizeDidUpdate()
    }

    return cell
  }
}
