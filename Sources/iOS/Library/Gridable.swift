import UIKit
import Sugar
import Brick

/// Gridable is protocol for Spots that are based on UICollectionView
public protocol Gridable: Spotable {
  // The layout object used to initialize the collection spot controller.
  var layout: UICollectionViewFlowLayout { get }
  /// The collection view object managed by this gridable object.
  var collectionView: UICollectionView { get }

  /**
   Asks the data source for the size of an item in a particular location.

   - Parameter indexPath: The index path of the
   - Returns: Size of the object at index path as CGSize
   */
  func sizeForItemAt(indexPath: NSIndexPath) -> CGSize
}

/// A Spotable extension for Gridable objects
public extension Spotable where Self : Gridable {

  /**
   Initializes a Gridable container and configures the Spot with the provided component and optional layout properties.

   - Parameter component: A Component model
   - Parameter top: The top UIEdgeInset for the layout
   - Parameter left: The left UIEdgeInset for the layout
   - Parameter bottom: The bottom UIEdgeInset for the layout
   - Parameter right: The right UIEdgeInset for the layout
   - Parameter itemSpacing: The minimumInteritemSpacing for the layout
   */
  public init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = UIEdgeInsetsMake(top, left, bottom, right)
    layout.minimumInteritemSpacing = itemSpacing
  }

  /**
   Called when the Gridable object is being prepared, it is required by Spotable
   */
  public func prepare() {
    registerAndPrepare { (classType, withIdentifier) in
      collectionView.registerClass(classType, forCellWithReuseIdentifier: withIdentifier)
    }

    var cached: UIView?
    for (index, item) in component.items.enumerate() {
      cachedViewFor(item, cache: &cached)

      if component.span > 0 {
        component.items[index].size.width = UIScreen.mainScreen().bounds.size.width / CGFloat(component.span)
      }
      (cached as? SpotConfigurable)?.configure(&component.items[index])
    }
  }

  /**
   - Parameter item: The view model that you want to append
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: Completion
   */
  public func append(item: ViewModel, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    var indexes = [Int]()
    let count = component.items.count

    for (index, item) in items.enumerate() {
      component.items.append(item)
      indexes.append(count + index)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      if count > 0 {
        weakSelf.collectionView.insert(indexes, completion: completion)
      } else {
        weakSelf.collectionView.reloadData()
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
    let itemsCount = component.items.count

    var cached: UIView?
    for (index, item) in items.enumerate() {
      component.items.append(item)
      indexes.append(itemsCount + index)
      prepareItem(item, index: itemsCount + index, cached: &cached)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      if count > 0 {
        weakSelf.collectionView.insert(indexes, completion: completion)
      } else {
        weakSelf.collectionView.reloadData()
        completion?()
      }
    }
  }

  /**
   - Parameter item: The view model that you want to insert
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter index: The index where the new ViewModel should be inserted
   - Parameter completion: Completion
   */
  public func insert(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    component.items.insert(item, atIndex: index)
    var indexes = [Int]()
    let count = component.items.count

    indexes.append(index)

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      if count > 0 {
        weakSelf.collectionView.insert(indexes, completion: completion)
      } else {
        weakSelf.collectionView.reloadData()
        completion?()
      }
    }
  }

  /**
   - Parameter item: A collection of view model that you want to prepend
   - Parameter animation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func prepend(items: [ViewModel], withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    var indexes = [Int]()

    component.items.insertContentsOf(items, at: 0)

    var cached: UIView?
    items.enumerate().forEach {
      indexes.append(items.count - 1 - $0.index)
      prepareItem($0.element, index: $0.index, cached: &cached)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      if count > 0 {
        weakSelf.collectionView.insert(indexes, completion: completion)
      } else {
        weakSelf.collectionView.reloadData()
        completion?()
      }
    }
  }

  /**
   - Parameter item: The view model that you want to remove
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func delete(item: ViewModel, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    guard let index = component.items.indexOf({ $0 == item })
      else { completion?(); return }

    perform(animation, withIndex: index) { [weak self] in
      guard let weakSelf = self else { return }

      if animation == .None { UIView.setAnimationsEnabled(false) }
      weakSelf.component.items.removeAtIndex(index)
      weakSelf.collectionView.delete([index], completion: completion)
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
    let count = component.items.count

    for (index, _) in items.enumerate() {
      indexes.append(count + index)
      component.items.removeAtIndex(count - index)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.collectionView.delete(indexes, completion: completion)
    }
  }

  /**
   - Parameter index: The index of the view model that you want to remove
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  func delete(index: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion) {
    perform(animation, withIndex: index) {
      dispatch { [weak self] in
        guard let weakSelf = self else { return }

        if animation == .None { UIView.setAnimationsEnabled(false) }
        weakSelf.component.items.removeAtIndex(index)
        weakSelf.collectionView.delete([index], completion: completion)
        if animation == .None { UIView.setAnimationsEnabled(true) }
      }
    }
  }

  /**
   - Parameter indexes: An array of indexes that you want to remove
   - Parameter withAnimation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  func delete(indexes: [Int], withAnimation animation: SpotsAnimation = .None, completion: Completion) {
    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.collectionView.delete(indexes, completion: completion)
    }
  }

  /**
   - Parameter item: The new update view model that you want to update at an index
   - Parameter index: The index of the view model, defaults to 0
   - Parameter animation: The animation that should be used (currently not in use)
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  public func update(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    items[index] = item

    let reuseIdentifier = reuseIdentifierForItem(NSIndexPath(forItem: index, inSection: 0))
    let cellClass = self.dynamicType.views.storage[reuseIdentifier] ?? self.dynamicType.defaultView

    collectionView.registerClass(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
    if let cell = cellClass.init() as? SpotConfigurable {
      component.items[index].index = index
      cell.configure(&component.items[index])
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.collectionView.reload([index], completion: completion)
    }
  }

  /**
   - Parameter indexes: An array of integers that you want to reload, default is nil
   - Parameter animated: Perform reload animation
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been reloaded
   */
  public func reload(indexes: [Int]? = nil, withAnimation animation: SpotsAnimation = .None, completion: Completion) {
    let items = component.items
    for (index, item) in items.enumerate() {
      let cellClass = self.dynamicType.views.storage[item.kind] ?? self.dynamicType.defaultView
      if let cell = cellClass.init() as? SpotConfigurable {
        component.items[index].index = index
        cell.configure(&component.items[index])
      }
    }

    collectionView.collectionViewLayout.invalidateLayout()
    collectionView.reloadData()
    setup(collectionView.bounds.size)
    collectionView.layoutIfNeeded()
    completion?()
  }

  /**
   - Returns: UIScrollView: Returns a UICollectionView as a UIScrollView
   */
  public func render() -> UIScrollView {
    return collectionView
  }

  /**
   - Parameter size: A CGSize to set the size of the collection view
   */
  public func setup(size: CGSize) {
    collectionView.frame.size = size
    GridSpot.configure?(view: collectionView, layout: layout)
  }

  /**
   - Parameter size: A CGSize to set the width and height of the collection view
   */
  public func layout(size: CGSize) {
    collectionView.collectionViewLayout.invalidateLayout()
    collectionView.width = size.width
    guard let componentSize = component.size else { return }
    collectionView.height = componentSize.height
  }

  /**
   Asks the data source for the size of an item in a particular location.

   - Parameter indexPath: The index path of the
   - Returns: Size of the object at index path as CGSize
   */
  public func sizeForItemAt(indexPath: NSIndexPath) -> CGSize {
    if component.span > 0 {
      component.items[indexPath.item].size.width = collectionView.width / CGFloat(component.span) - layout.minimumInteritemSpacing
    }

    let width = item(indexPath).size.width - collectionView.contentInset.left - layout.sectionInset.left - layout.sectionInset.right

    // Never return a negative width
    guard width > -1 else { return CGSizeZero }

    return CGSize(
      width: floor(width),
      height: ceil(item(indexPath).size.height))
  }

  /**
   Perform animation before mutation

   - Parameter spotAnimation: The animation that you want to apply
   - Parameter withIndex: The index of the cell
   - Parameter completion: A completion block that runs after applying the animation
   */
  private func perform(spotAnimation: SpotsAnimation, withIndex index: Int, completion: () -> Void) {
    guard let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0))
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
      animation.toValue = -cell.frame.width - collectionView.contentOffset.x
    case .Right:
      animation.keyPath = "position.x"
      animation.toValue = cell.frame.width + collectionView.frame.size.width + collectionView.contentOffset.x
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
