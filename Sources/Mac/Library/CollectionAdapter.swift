import Cocoa
import Brick
import Sugar

/**
 The CollectionAdapter works as a proxy handler for all Gridable object
 */
public class CollectionAdapter: NSObject, SpotAdapter {
  // An unowned Gridable object
  var spot: Gridable

  /**
   Initialization a new instance of a ListAdapter using a Gridable object

   - Parameter gridable: A Listable object
   */
  init(spot: Gridable) {
    self.spot = spot
  }
}

extension CollectionAdapter {

  public func append(item: ViewModel, withAnimation animation: SpotsAnimation, completion: Completion) {
    let count = spot.component.items.count
    spot.component.items.append(item)

    dispatch { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.insert([count], completion: {
        self?.spot.setup(collectionView.frame.size)
        completion?()
      })
    }
  }
  public func append(items: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion) {
    var indexes = [Int]()
    let count = spot.component.items.count

    spot.component.items.appendContentsOf(items)

    items.enumerate().forEach {
      indexes.append(count + $0.index)
    }

    dispatch { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.insert(indexes) {
        self?.spot.setup(collectionView.frame.size)
        completion?()
      }
    }
  }

  public func prepend(items: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion) {
    var indexes = [Int]()

    spot.component.items.insertContentsOf(items, at: 0)

    items.enumerate().forEach {
      indexes.append(items.count - 1 - $0.index)
    }

    dispatch { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.insert(indexes) {
        self?.refreshHeight()
      }
    }
  }

  public func insert(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {
    spot.component.items.insert(item, atIndex: index)

    dispatch { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.insert([index]) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func update(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {
    spot.items[index] = item

    dispatch { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.reload([index], section: 0) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(item: ViewModel, withAnimation animation: SpotsAnimation, completion: Completion) {
    guard let index = spot.component.items.indexOf({ $0 == item })
      else { completion?(); return }

    spot.component.items.removeAtIndex(index)

    dispatch { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.delete([index]) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(item: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion) {
    var indexPaths = [Int]()
    let count = spot.component.items.count

    for (index, item) in spot.items.enumerate() {
      indexPaths.append(count + index)
      spot.component.items.append(item)
    }

    dispatch { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.delete(indexPaths) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {
    dispatch { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      self?.spot.component.items.removeAtIndex(index)
      collectionView.delete([index]) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(indexes: [Int], withAnimation animation: SpotsAnimation, completion: Completion) {
    dispatch { [weak self] in
      indexes.forEach { self?.spot.component.items.removeAtIndex($0) }
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.delete(indexes) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func reload(indexes: [Int]?, withAnimation animation: SpotsAnimation, completion: Completion) {
    dispatch { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      if let indexes = indexes where animation != .None {
        collectionView.reload(indexes) {
          self?.refreshHeight(completion)
        }
      } else {
        collectionView.reloadData()
        self?.spot.setup(collectionView.frame.size)
        completion?()
      }
    }
  }

  public func refreshHeight(completion: (() -> Void)? = nil) {
    delay(0.2) { [weak self] in
      guard let weakSelf = self, collectionView = self?.spot.collectionView else { return; completion?() }
      weakSelf.spot.setup(CGSize(width: collectionView.frame.width, height: weakSelf.spot.spotHeight() ?? 0))
      completion?()
    }
  }
}

extension CollectionAdapter : NSCollectionViewDelegate {

  public func collectionView(collectionView: NSCollectionView, didSelectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
    guard let first = indexPaths.first else { return }
    let item = spot.items[first.item]
    spot.spotsDelegate?.spotDidSelectItem(spot, item: item)
  }
}

extension CollectionAdapter: NSCollectionViewDataSource {

  public func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
    return 1
  }

  public func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return spot.component.items.count
  }

  public func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
    let reuseIdentifier = spot.reuseIdentifierForItem(indexPath.item)
    let item = collectionView.makeItemWithIdentifier(reuseIdentifier, forIndexPath: indexPath)

    (item as? SpotConfigurable)?.configure(&spot.component.items[indexPath.item])
    return item
  }
}

extension CollectionAdapter: NSCollectionViewDelegateFlowLayout {

  public func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> NSSize {
    return spot.sizeForItemAt(indexPath)
  }
}
