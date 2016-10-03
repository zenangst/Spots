import Cocoa
import Brick

extension CollectionAdapter {

  public func ui<T>(atIndex index: Int) -> T? {
    return spot.collectionView.item(at: IndexPath(item: index, section: 0) as IndexPath) as? T
  }

  public func append(_ item: Item, withAnimation animation: SpotsAnimation, completion: Completion) {
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
  public func append(_ items: [Item], withAnimation animation: SpotsAnimation, completion: Completion) {
    var indexes = [Int]()
    let count = spot.component.items.count

    spot.component.items.append(contentsOf: items)

    items.enumerated().forEach {
      indexes.append(count + $0.offset)
    }

    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.insert(indexes) {
        self?.spot.setup(collectionView.frame.size)
        completion?()
      }
    }
  }

  public func prepend(_ items: [Item], withAnimation animation: SpotsAnimation, completion: Completion) {
    var indexes = [Int]()

    spot.component.items.insert(contentsOf: items, at: 0)

    items.enumerated().forEach {
      indexes.append(items.count - 1 - $0.offset)
    }

    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.insert(indexes) {
        self?.refreshHeight()
      }
    }
  }

  public func insert(_ item: Item, index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {
    spot.component.items.insert(item, at: index)

    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.insert([index]) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func update(_ item: Item, index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {
    spot.items[index] = item

    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.reload([index], section: 0) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(_ item: Item, withAnimation animation: SpotsAnimation, completion: Completion) {
    guard let index = spot.component.items.index(where: { $0 == item })
      else { completion?(); return }

    spot.component.items.remove(at: index)

    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.delete([index]) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(_ item: [Item], withAnimation animation: SpotsAnimation, completion: Completion) {
    var indexPaths = [Int]()
    let count = spot.component.items.count

    for (index, item) in spot.items.enumerated() {
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

  public func delete(_ index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {
    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      self?.spot.component.items.remove(at: index)
      collectionView.delete([index]) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(_ indexes: [Int], withAnimation animation: SpotsAnimation, completion: Completion) {
    Dispatch.mainQueue { [weak self] in
      indexes.forEach { self?.spot.component.items.remove(at: $0) }
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      collectionView.delete(indexes) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: SpotsAnimation, updateDataSource: () -> Void, completion: Completion) {
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

  public func reload(_ indexes: [Int]?, withAnimation animation: SpotsAnimation, completion: Completion) {
    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.spot.collectionView else { completion?(); return }
      if let indexes = indexes , animation != .none {
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

  public func refreshHeight(_ completion: (() -> Void)? = nil) {
    Dispatch.delay(for: 0.2) { [weak self] in
      guard let weakSelf = self, let collectionView = self?.spot.collectionView else { return; completion?() }
      weakSelf.spot.setup(CGSize(width: collectionView.frame.width, height: weakSelf.spot.spotHeight() ))
      completion?()
    }
  }
}
