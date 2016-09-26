import Cocoa
import Brick

extension CollectionAdapter {

  public func ui<T>(atIndex index: Int) -> T? {
    return spot.collectionView.itemAtIndexPath(NSIndexPath(forItem: index, inSection: 0)) as? T
  }

  public func append(item: Item, withAnimation animation: SpotsAnimation, completion: Completion) {
    let count = spot.component.items.count
    spot.component.items.append(item)

    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.insert([count], completion: {
        self?.spot.setup(collectionView.frame.size)
        completion?()
      })
    }
  }
  public func append(items: [Item], withAnimation animation: SpotsAnimation, completion: Completion) {
    var indexes = [Int]()
    let count = spot.component.items.count

    spot.component.items.appendContentsOf(items)

    items.enumerate().forEach {
      indexes.append(count + $0.index)
    }

    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.insert(indexes) {
        self?.spot.setup(collectionView.frame.size)
        completion?()
      }
    }
  }

  public func prepend(items: [Item], withAnimation animation: SpotsAnimation, completion: Completion) {
    var indexes = [Int]()

    spot.component.items.insertContentsOf(items, at: 0)

    items.enumerate().forEach {
      indexes.append(items.count - 1 - $0.index)
    }

    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.insert(indexes) {
        self?.refreshHeight()
      }
    }
  }

  public func insert(item: Item, index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {
    spot.component.items.insert(item, atIndex: index)

    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.insert([index]) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func update(item: Item, index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {
    spot.items[index] = item

    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.reload([index], section: 0) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(item: Item, withAnimation animation: SpotsAnimation, completion: Completion) {
    guard let index = spot.component.items.indexOf({ $0 == item })
      else { completion?(); return }

    spot.component.items.removeAtIndex(index)

    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.delete([index]) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(item: [Item], withAnimation animation: SpotsAnimation, completion: Completion) {
    var indexPaths = [Int]()
    let count = spot.component.items.count

    for (index, item) in spot.items.enumerate() {
      indexPaths.append(count + index)
      spot.component.items.append(item)
    }

    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.delete(indexPaths) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {
    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      self?.spot.component.items.removeAtIndex(index)
      collectionView.delete([index]) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(indexes: [Int], withAnimation animation: SpotsAnimation, completion: Completion) {
    Dispatch.mainQueue { [weak self] in
      indexes.forEach { self?.spot.component.items.removeAtIndex($0) }
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.delete(indexes) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func reloadIfNeeded(changes: ItemChanges, withAnimation animation: SpotsAnimation, updateDataSource: () -> Void, completion: Completion) {
    guard !changes.updates.isEmpty else {
      spot.collectionView.process((insertions: changes.insertions, reloads: changes.reloads, deletions: changes.deletions), updateDataSource: updateDataSource, completion: completion)
      return
    }

    spot.collectionView.process((insertions: changes.insertions, reloads: changes.reloads, deletions: changes.deletions), updateDataSource: updateDataSource) {

      for index in changes.updates {
        guard let item = self.spot.item(index) else { continue }
        self.spot.update(item, index: index, withAnimation: animation, completion: completion)
      }
    }
  }

  public func reload(indexes: [Int]?, withAnimation animation: SpotsAnimation, completion: Completion) {
    Dispatch.mainQueue { [weak self] in
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
    Dispatch.delay(for: 0.2) { [weak self] in
      guard let weakSelf = self, collectionView = self?.spot.collectionView else { return; completion?() }
      weakSelf.spot.setup(CGSize(width: collectionView.frame.width, height: weakSelf.spot.spotHeight() ?? 0))
      completion?()
    }
  }
}
