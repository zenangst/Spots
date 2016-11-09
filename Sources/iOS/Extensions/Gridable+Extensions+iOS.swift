import UIKit
import Brick

extension Gridable {

  /// A computed CGFloat of the total height of all items inside of a component.
  public var computedHeight: CGFloat {
    guard usesDynamicHeight else {
      return self.render().frame.height
    }

    layout.prepare()

    return layout.collectionViewContentSize.height + layout.sectionInset.top + layout.sectionInset.bottom
  }

  /// Initializes a Gridable container and configures the Spot with the provided component and optional layout properties.
  ///
  /// - parameter component: A Component model.
  /// - parameter top: The top UIEdgeInset for the layout.
  /// - parameter left: The left UIEdgeInset for the layout.
  /// - parameter bottom: The bottom UIEdgeInset for the layout.
  /// - parameter right: The right UIEdgeInset for the layout.
  /// - parameter itemSpacing: The minimumInteritemSpacing for the layout.
  public init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = EdgeInsets(top: top, left: left, bottom: bottom, right: right)
    layout.minimumInteritemSpacing = itemSpacing
  }

  /// Asks the data source for the size of an item in a particular location.
  ///
  /// - parameter indexPath: The index path of the
  ///
  /// - returns: Size of the object at index path as CGSize
  public func sizeForItem(at indexPath: IndexPath) -> CGSize {
    let width = (item(at: indexPath)?.size.width ?? 0) - collectionView.contentInset.left - collectionView.contentInset.right - layout.sectionInset.left - layout.sectionInset.right
    let height = item(at: indexPath)?.size.height ?? 0

    // Never return a negative width
    guard width > -1 else { return CGSize.zero }

    return CGSize(
      width: floor(width),
      height: ceil(height)
    )
  }

  /// Layout with size
  ///
  /// - parameter size: A CGSize to set the width and height of the collection view
  public func layout(_ size: CGSize) {
    prepareItems()
    layout.prepare()
    layout.invalidateLayout()
    collectionView.frame.size.width = layout.collectionViewContentSize.width
    collectionView.frame.size.height = layout.collectionViewContentSize.height
  }

  /// Perform animation before mutation
  ///
  /// - parameter spotAnimation: The animation that you want to apply
  /// - parameter withIndex: The index of the cell
  /// - parameter completion: A completion block that runs after applying the animation
  public func perform(_ spotAnimation: Animation, withIndex index: Int, completion: () -> Void) {
    guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0))
      else { completion(); return }

    let animation = CABasicAnimation()

    switch spotAnimation {
    case .top:
      animation.keyPath = "position.y"
      animation.toValue = -cell.frame.height
    case .bottom:
      animation.keyPath = "position.y"
      animation.toValue = cell.frame.height * 2
    case .left:
      animation.keyPath = "position.x"
      animation.toValue = -cell.frame.width - collectionView.contentOffset.x
    case .right:
      animation.keyPath = "position.x"
      animation.toValue = cell.frame.width + collectionView.frame.size.width + collectionView.contentOffset.x
    case .fade:
      animation.keyPath = "opacity"
      animation.toValue = 0.0
    case .middle:
      animation.keyPath = "transform.scale.y"
      animation.toValue = 0.0
    case .automatic:
      animation.keyPath = "transform.scale"
      animation.toValue = 0.0
    default:
      break
    }

    animation.duration = 0.3
    cell.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    cell.layer.add(animation, forKey: "Animation")
    completion()
  }

  // MARK: - Spotable

  /// Register all views in Registry on UICollectionView
  public func register() {
    for (identifier, item) in type(of: self).views.storage {
      switch item {
      case .classType(let classType):
        self.collectionView.register(classType, forCellWithReuseIdentifier: identifier)
      case .nib(let nib):
        self.collectionView.register(nib, forCellWithReuseIdentifier: identifier)
      }
    }

    for (identifier, item) in type(of: self).headers.storage {
      switch item {
      case .classType(let classType):
        self.collectionView.register(classType,
                                          forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                          withReuseIdentifier: identifier)
      case .nib(let nib):
        self.collectionView.register(nib,
                                        forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                        withReuseIdentifier: identifier)
      }
    }
  }

  /// Add header view class to Registry
  ///
  /// - parameter header:     The view type that you want to register
  /// - parameter identifier: The identifier for the header
  public static func register(header: View.Type, identifier: StringConvertible) {
    self.headers.storage[identifier.string] = Registry.Item.classType(header)
  }

  /// Add header nib-based view class to Registry
  ///
  /// - parameter header:     The nib file that is used by the view
  /// - parameter identifier: The identifier for the nib-based header
  public static func register(header nib: Nib, identifier: StringConvertible) {
    self.headers.storage[identifier.string] = Registry.Item.nib(nib)
  }

  /// Register default header for the CarouselSpot
  ///
  /// - parameter view: A header view
  public func registerDefaultHeader(header view: View.Type) {
    guard type.headers.storage[type.headers.defaultIdentifier] == nil else { return }
    type.headers.defaultItem = Registry.Item.classType(view)
  }

  ///Register a default header for the Gridable component
  ///
  /// - parameter defaultHeader: The default header class that should be used by the component
  public static func register(defaultHeader header: View.Type) {
    self.headers.storage[self.views.defaultIdentifier] = Registry.Item.classType(header)
    self.headers.defaultItem = Registry.Item.classType(header)
  }

  public func ui<T>(at index: Int) -> T? {
    return collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? T
  }

  /// Append item to collection with animation
  ///
  /// - parameter item: The view model that you want to append.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func append(_ item: Item, withAnimation animation: Animation = .none, completion: Completion = nil) {
    let operation = SpotOperation { [weak self] finish in
      guard let weakSelf = self else { completion?(); return }

      var indexes = [Int]()
      let itemsCount = weakSelf.component.items.count

      if weakSelf.component.items.isEmpty {
        weakSelf.component.items.append(item)
      } else {
        for (index, item) in weakSelf.items.enumerated() {
          weakSelf.component.items.append(item)
          indexes.append(itemsCount + index)
        }
      }

      Dispatch.mainQueue { [weak self] in
        guard let weakSelf = self else { completion?(); return }

        if itemsCount > 0 {
          weakSelf.collectionView.insert(indexes, completion: nil)
        } else {
          weakSelf.collectionView.reloadData()
        }
        weakSelf.updateHeight() {
          completion?()
        }
      }
    }

    operationQueue.addOperation(operation)
  }

  /// Append a collection of items to collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to insert
  /// - parameter animation:  The animation that should be used (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func append(_ items: [Item], withAnimation animation: Animation = .none, completion: Completion = nil) {
    var indexes = [Int]()
    let itemsCount = component.items.count

    if component.items.isEmpty {
      component.items.append(contentsOf: items)
    } else {
      for (index, item) in items.enumerated() {
        component.items.append(item)
        indexes.append(itemsCount + index)

        configureItem(at: itemsCount + index)
      }
    }

    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      if itemsCount > 0 {
        weakSelf.collectionView.insert(indexes, completion: nil)
      } else {
        weakSelf.collectionView.reloadData()
      }
      weakSelf.updateHeight() {
        completion?()
      }
    }
  }

  /// Insert item into collection at index.
  ///
  /// - parameter item:       The view model that you want to insert.
  /// - parameter index:      The index where the new Item should be inserted.
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func insert(_ item: Item, index: Int, withAnimation animation: Animation = .none, completion: Completion = nil) {
    let itemsCount = component.items.count
    component.items.insert(item, at: index)
    var indexes = [Int]()

    if itemsCount > 0 {
      indexes.append(index)
    }

    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      if itemsCount > 0 {
        weakSelf.collectionView.insert(indexes, completion: nil)
      } else {
        weakSelf.collectionView.reloadData()
      }
      weakSelf.sanitize { completion?() }
    }
  }

  /// Prepend a collection items to the collection with animation
  ///
  /// - parameter items:      A collection of view model that you want to prepend
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use)
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func prepend(_ items: [Item], withAnimation animation: Animation = .none, completion: Completion = nil) {
    let itemsCount = component.items.count
    var indexes = [Int]()

    component.items.insert(contentsOf: items, at: 0)

    items.enumerated().forEach {
      if itemsCount > 0 {
        indexes.append(items.count - 1 - $0.offset)
      }
      configureItem(at: $0.offset)
    }

    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      if !indexes.isEmpty {
        weakSelf.collectionView.insert(indexes) {
          weakSelf.sanitize { completion?() }
        }
      } else {
        weakSelf.collectionView.reloadData()
        weakSelf.sanitize { completion?() }
      }
    }
  }

  /// Delete item from collection with animation
  ///
  /// - parameter item:       The view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func delete(_ item: Item, withAnimation animation: Animation = .none, completion: Completion = nil) {
    guard let index = component.items.index(where: { $0 == item })
      else { completion?(); return }

    perform(animation, withIndex: index) { [weak self] in
      guard let weakSelf = self else { completion?(); return }

      if animation == .none { UIView.setAnimationsEnabled(false) }
      weakSelf.component.items.remove(at: index)
      weakSelf.collectionView.delete([index], completion: nil)
      if animation == .none { UIView.setAnimationsEnabled(true) }

      weakSelf.sanitize { completion?() }
    }
  }

  /// Delete items from collection with animation
  ///
  /// - parameter items:      A collection of view models that you want to delete.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue.
  public func delete(_ items: [Item], withAnimation animation: Animation = .none, completion: Completion = nil) {
    var indexes = [Int]()
    let count = component.items.count

    for (index, _) in items.enumerated() {
      indexes.append(count + index)
      component.items.remove(at: count - index)
    }

    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { completion?(); return }
      weakSelf.collectionView.delete(indexes) {
        weakSelf.sanitize { completion?() }
      }
    }
  }

  /// Delete item at index with animation
  ///
  /// - parameter index:      The index of the view model that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  public func delete(_ index: Int, withAnimation animation: Animation = .none, completion: Completion) {
    perform(animation, withIndex: index) {
      Dispatch.mainQueue { [weak self] in
        guard let weakSelf = self else { completion?(); return }

        if animation == .none { UIView.setAnimationsEnabled(false) }
        weakSelf.component.items.remove(at: index)
        weakSelf.collectionView.delete([index], completion: nil)
        if animation == .none { UIView.setAnimationsEnabled(true) }
        weakSelf.sanitize { completion?() }
      }
    }
  }

  /// Delete a collection
  ///
  /// - parameter indexes:    An array of indexes that you want to remove.
  /// - parameter animation:  The animation that should be used (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  public func delete(_ indexes: [Int], withAnimation animation: Animation = .none, completion: Completion) {
    Dispatch.mainQueue { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.collectionView.delete(indexes) {
        weakSelf.sanitize { completion?() }
      }
    }
  }

  /// Update item at index with new item.
  ///
  /// - parameter item:       The new update view model that you want to update at an index.
  /// - parameter index:      The index of the view model, defaults to 0.
  /// - parameter animation:  A Animation that is used when performing the mutation (currently not in use).
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been removed.
  public func update(_ item: Item, index: Int, withAnimation animation: Animation = .none, completion: Completion = nil) {
    guard let oldItem = self.item(at: index) else { completion?(); return }

    var item = item
    item.index = index
    items[index] = item
    configureItem(at: index)

    let newItem = items[index]
    let indexPath = IndexPath(item: index, section: 0)

    if let composite = collectionView.cellForItem(at: indexPath) as? Composable {
      if let spots = spotsCompositeDelegate?.resolve(index, itemIndex: (indexPath as NSIndexPath).item) {
        collectionView.performBatchUpdates({
          composite.configure(&self.component.items[indexPath.item], spots: spots)
          }, completion: nil)
        completion?()
        return
      }
    }

    if newItem.kind != oldItem.kind || newItem.size.height != oldItem.size.height {
      if let cell = collectionView.cellForItem(at: indexPath) as? SpotConfigurable {
        if animation != .none {
          collectionView.performBatchUpdates({
            }, completion: { (_) in })
        }
        cell.configure(&self.items[index])
      }
    } else if let cell = collectionView.cellForItem(at: indexPath) as? SpotConfigurable {
      cell.configure(&items[index])
    }

    completion?()
  }

  /// Reload with indexes
  ///
  /// - parameter indexes:    An array of integers that you want to reload, default is nil.
  /// - parameter animation:  Perform reload animation.
  /// - parameter completion: A completion closure that is executed in the main queue when the view model has been reloaded.
  public func reload(_ indexes: [Int]? = nil, withAnimation animation: Animation = .none, completion: Completion) {
    if animation == .none { UIView.setAnimationsEnabled(false) }

    refreshIndexes()
    var cellCache: [String : SpotConfigurable] = [:]

    if let indexes = indexes {
      indexes.forEach { index  in
        configureItem(at: index)
      }
    } else {
      component.items.enumerated().forEach { index, _  in
        configureItem(at: index)
      }
    }

    cellCache.removeAll()

    if let indexes = indexes {
      collectionView.reload(indexes)
    } else {
      collectionView.reloadData()
    }

    setup(collectionView.bounds.size)
    collectionView.layoutIfNeeded()

    if animation == .none { UIView.setAnimationsEnabled(true) }
    completion?()
  }

  public func beforeUpdate() {
    CATransaction.begin()
  }

  public func afterUpdate() {
    CATransaction.commit()
  }
}
