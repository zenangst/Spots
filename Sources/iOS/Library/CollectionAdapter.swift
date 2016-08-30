import UIKit
import Brick
import Sugar

/**
 The CollectionAdapter works as a proxy handler for all Gridable object
 */
public class CollectionAdapter: NSObject, SpotAdapter {
  // An unowned Gridable object
  unowned var spot: Gridable

  /**
   Initialization a new instance of a CollectionAdapter using a Gridable object

   - Parameter spot: A Gridable object
   */
  init(spot: Gridable) {
    self.spot = spot
  }

  /**
   - Parameter item: The view model that you want to append
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: Completion
   */
  public func append(item: ViewModel, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    var indexes = [Int]()
    let itemsCount = spot.component.items.count

    for (index, item) in spot.items.enumerate() {
      spot.component.items.append(item)
      indexes.append(itemsCount + index)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      if itemsCount > 0 {
        weakSelf.spot.collectionView.insert(indexes, completion: completion)
      } else {
        weakSelf.spot.collectionView.reloadData()
        completion?()
      }
    }
  }

  /**
   - Parameter items: A collection of view models that you want to insert
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: Completion
   */
  public func append(items: [ViewModel], withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    var indexes = [Int]()
    let itemsCount = spot.component.items.count

    for (index, item) in items.enumerate() {
      spot.component.items.append(item)
      indexes.append(itemsCount + index)

      spot.configureItem(itemsCount + index)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      if itemsCount > 0 {
        weakSelf.spot.collectionView.insert(indexes, completion: completion)
      } else {
        weakSelf.spot.collectionView.reloadData()
        completion?()
      }
    }
  }

  /**
   - Parameter item: The view model that you want to insert
   - Parameter index: The index where the new ViewModel should be inserted
   - Parameter animation: The animation that should be used (currently not in use)
   - Parameter completion: Completion
   */
  public func insert(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot.component.items.insert(item, atIndex: index)
    var indexes = [Int]()
    let itemsCount = spot.component.items.count

    indexes.append(index)

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      if itemsCount > 0 {
        weakSelf.spot.collectionView.insert(indexes, completion: completion)
      } else {
        weakSelf.spot.collectionView.reloadData()
        completion?()
      }
    }
  }

  /**
   - Parameter items: A collection of view model that you want to prepend
   - Parameter animation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func prepend(items: [ViewModel], withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    var indexes = [Int]()

    spot.component.items.insertContentsOf(items, at: 0)

    items.enumerate().forEach {
      indexes.append(items.count - 1 - $0.index)
      spot.configureItem($0.index)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      weakSelf.spot.collectionView.insert(indexes, completion: completion)
    }
  }

  /**
   - Parameter item: The view model that you want to remove
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func delete(item: ViewModel, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    guard let index = spot.component.items.indexOf({ $0 == item })
      else { completion?(); return }

    perform(animation, withIndex: index) { [weak self] in
      guard let weakSelf = self else { return }

      if animation == .None { UIView.setAnimationsEnabled(false) }
      weakSelf.spot.component.items.removeAtIndex(index)
      weakSelf.spot.collectionView.delete([index], completion: completion)
      if animation == .None { UIView.setAnimationsEnabled(true) }
    }
  }

  /**
   - Parameter items: A collection of view models that you want to delete
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func delete(items: [ViewModel], withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    var indexes = [Int]()
    let count = spot.component.items.count

    for (index, _) in items.enumerate() {
      indexes.append(count + index)
      spot.component.items.removeAtIndex(count - index)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.spot.collectionView.delete(indexes, completion: completion)
    }
  }

  /**
   - Parameter index: The index of the view model that you want to remove
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  public func delete(index: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion) {
    perform(animation, withIndex: index) {
      dispatch { [weak self] in
        guard let weakSelf = self else { return }

        if animation == .None { UIView.setAnimationsEnabled(false) }
        weakSelf.spot.component.items.removeAtIndex(index)
        weakSelf.spot.collectionView.delete([index], completion: completion)
        if animation == .None { UIView.setAnimationsEnabled(true) }
      }
    }
  }

  /**
   - Parameter indexes: An array of indexes that you want to remove
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  public func delete(indexes: [Int], withAnimation animation: SpotsAnimation = .None, completion: Completion) {
    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.spot.collectionView.delete(indexes, completion: completion)
    }
  }

  /**
   - Parameter item: The new update view model that you want to update at an index
   - Parameter index: The index of the view model, defaults to 0
   - Parameter animation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  public func update(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {

    let oldItem = spot.items[index]

    spot.items[index] = item
    spot.configureItem(index)

    let newItem = spot.items[index]
    let indexPath = NSIndexPath(forItem: index, inSection: 0)

    if newItem.kind != oldItem.kind || newItem.size.height != oldItem.size.height {
      if let cell = spot.collectionView.cellForItemAtIndexPath(indexPath) as? SpotConfigurable {
        spot.collectionView.performBatchUpdates({
          }, completion: { (_) in
            cell.configure(&self.spot.items[index])
        })
      } else {
        spot.collectionView.reload([index], section: 0)
      }
    } else if let cell = spot.collectionView.cellForItemAtIndexPath(indexPath) as? SpotConfigurable {
      cell.configure(&spot.items[index])
    }

    completion?()
  }

  /**
   - Parameter indexes: An array of integers that you want to reload, default is nil
   - Parameter animation: Perform reload animation
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been reloaded
   */
  public func reload(indexes: [Int]? = nil, withAnimation animation: SpotsAnimation = .None, completion: Completion) {
    spot.refreshIndexes()
    var cellCache: [String : SpotConfigurable] = [:]

    if let indexes = indexes {
      indexes.forEach { index  in
        spot.configureItem(index)
      }
    } else {
      spot.component.items.enumerate().forEach { index, _  in
        spot.configureItem(index)
      }
    }

    cellCache.removeAll()
    spot.collectionView.collectionViewLayout.invalidateLayout()

    if let indexes = indexes {
      spot.collectionView.reload(indexes)
    } else {
      spot.collectionView.reloadData()
    }

    spot.setup(spot.collectionView.bounds.size)
    spot.collectionView.layoutIfNeeded()
    completion?()
  }
}

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

extension CollectionAdapter : UICollectionViewDelegate {

  public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let header = spot.component.header.isEmpty
      ? spot.dynamicType.headers.defaultIdentifier
      : spot.component.header

    let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: header, forIndexPath: indexPath)
    (view as? Componentable)?.configure(spot.component)

    return view
  }

  /**
   Asks the delegate for the size of the specified item’s cell.

   - Parameter collectionView: The collection view object displaying the flow layout.
   - Parameter collectionViewLayout: The layout object requesting the information.
   - Parameter indexPath: The index path of the item.
   - Returns: The width and height of the specified item. Both values must be greater than 0.
   */
  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return spot.sizeForItemAt(indexPath)
  }

  /**
   Tells the delegate that the item at the specified index path was selected.

   - Parameter collectionView: The collection view object that is notifying you of the selection change.
   - Parameter indexPath: The index path of the cell that was selected.
   */
  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let item = spot.item(indexPath) {
      spot.spotsDelegate?.spotDidSelectItem(spot, item: item)
    }
  }

  /**
   Asks the delegate whether the item at the specified index path can be focused.

   - Parameter collectionView: The collection view object requesting this information.
   - Parameter indexPath:      The index path of an item in the collection view.
   - Returns: YES if the item can receive be focused or NO if it can not.
   */
  public func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }

  /**
   Asks the delegate whether a change in focus should occur.

   - Parameter collectionView: The collection view object requesting this information.
   - Parameter context:        The context object containing metadata associated with the focus change.
   This object contains the index path of the previously focused item and the item targeted to receive focus next. Use this information to determine if the focus change should occur.
   - Returns: YES if the focus change should occur or NO if it should not.
   */
  @available(iOS 9.0, *)
  public func collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool {
    guard let indexPaths = collectionView.indexPathsForSelectedItems() else { return true }
    return indexPaths.isEmpty
  }

  /**
   Perform animation before mutation

   - Parameter spotAnimation: The animation that you want to apply
   - Parameter withIndex: The index of the cell
   - Parameter completion: A completion block that runs after applying the animation
   */
  public func perform(spotAnimation: SpotsAnimation, withIndex index: Int, completion: () -> Void) {
    guard let cell = spot.collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0))
      else { completion(); return }

    let animation = CABasicAnimation()

    switch spotAnimation {
    case .Top:
      animation.keyPath = "position.y"
      animation.toValue = -cell.frame.height
    case .Bottom:
      animation.keyPath = "position.y"
      animation.toValue = cell.frame.height * 2
    case .Left:
      animation.keyPath = "position.x"
      animation.toValue = -cell.frame.width - spot.collectionView.contentOffset.x
    case .Right:
      animation.keyPath = "position.x"
      animation.toValue = cell.frame.width + spot.collectionView.frame.size.width + spot.collectionView.contentOffset.x
    case .Fade:
      animation.keyPath = "opacity"
      animation.toValue = 0.0
    case .Middle:
      animation.keyPath = "transform.scale.y"
      animation.toValue = 0.0
    case .Automatic:
      animation.keyPath = "transform.scale"
      animation.toValue = 0.0
    default:
      break
    }

    animation.duration = 0.3
    cell.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    cell.layer.addAnimation(animation, forKey: "SpotAnimation")
    completion()
  }
}

extension CollectionAdapter : UICollectionViewDataSource {

  /**
   Asks the data source for the number of items in the specified section. (required)

   - Parameter collectionView: An object representing the collection view requesting this information.
   - Parameter section: An index number identifying a section in collectionView. This index value is 0-based.
   - Returns: The number of rows in section.
   */
  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return spot.component.items.count
  }

  /**
   Asks the data source for the cell that corresponds to the specified item in the collection view. (required)

   - Parameter collectionView: An object representing the collection view requesting this information.
   - Parameter indexPath: The index path that specifies the location of the item.
   - Returns: A configured cell object. You must not return nil from this method.
 */
  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    spot.component.items[indexPath.item].index = indexPath.item

    let reuseIdentifier = spot.identifier(indexPath)
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)

    #if os(iOS)
      cell.optimize()
    #endif

    if let composite = cell as? SpotComposable {
      let spots = spot.spotsCompositeDelegate?.compositeSpots[spot.index]?[indexPath.item]
      composite.configure(&spot.component.items[indexPath.item], spots: spots)
    } else if let cell = cell as? SpotConfigurable {
      cell.configure(&spot.component.items[indexPath.item])
      if spot.component.items[indexPath.item].size.height == 0.0 {
        spot.component.items[indexPath.item].size = cell.size
      }
      spot.configure?(cell)
    }

    collectionView.collectionViewLayout.invalidateLayout()

    return cell
  }
}

extension CollectionAdapter: UICollectionViewDelegateFlowLayout {

  /**
   Asks the delegate for the spacing between successive rows or columns of a section.

   - Parameter collectionView:       The collection view object displaying the flow layout.
   - Parameter collectionViewLayout: The layout object requesting the information.
   - Parameter section:              The index number of the section whose line spacing is needed.
   - Returns: The minimum space (measured in points) to apply between successive lines in a section.
   */
  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    guard spot.layout.scrollDirection == .Horizontal else { return spot.layout.sectionInset.bottom }

    return spot.layout.minimumLineSpacing
  }

  /**
   Asks the delegate for the margins to apply to content in the specified section.

   - Parameter collectionView:       The collection view object displaying the flow layout.
   - Parameter collectionViewLayout: The layout object requesting the information.
   - Parameter section:              The index number of the section whose insets are needed.
   - Returns: The margins to apply to items in the section.
   */
  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    guard spot.layout.scrollDirection == .Horizontal else { return spot.layout.sectionInset }

    let left = spot.layout.minimumLineSpacing / 2
    let right = spot.layout.minimumLineSpacing / 2

    return UIEdgeInsets(top: spot.layout.sectionInset.top,
                        left: left,
                        bottom: spot.layout.sectionInset.bottom,
                        right: right)
  }
}
