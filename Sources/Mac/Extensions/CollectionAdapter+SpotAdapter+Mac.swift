import Cocoa
import Brick

extension Gridable {

  public func ui<T>(at index: Int) -> T? {
    return collectionView.item(at: IndexPath(item: index, section: 0)) as? T
  }

  public func append(_ item: Item, withAnimation animation: SpotsAnimation, completion: Completion) {
    let count = component.items.count
    component.items.append(item)

    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.collectionView else { completion?(); return }
      collectionView.insert([count], completion: {
        self?.setup(collectionView.frame.size)
        completion?()
      })
    }
  }
  public func append(_ items: [Item], withAnimation animation: SpotsAnimation, completion: Completion) {
    var indexes = [Int]()
    let count = component.items.count

    component.items.append(contentsOf: items)

    items.enumerated().forEach {
      indexes.append(count + $0.offset)
    }

    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.collectionView else { completion?(); return }
      collectionView.insert(indexes) {
        self?.setup(collectionView.frame.size)
        completion?()
      }
    }
  }

  public func prepend(_ items: [Item], withAnimation animation: SpotsAnimation, completion: Completion) {
    var indexes = [Int]()

    component.items.insert(contentsOf: items, at: 0)

    items.enumerated().forEach {
      indexes.append(items.count - 1 - $0.offset)
    }

    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.collectionView else { completion?(); return }
      collectionView.insert(indexes) {
        self?.refreshHeight()
      }
    }
  }

  public func insert(_ item: Item, index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {
    component.items.insert(item, at: index)

    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.collectionView else { completion?(); return }
      collectionView.insert([index]) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func update(_ item: Item, index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {
    items[index] = item

    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.collectionView else { completion?(); return }
      collectionView.reload([index], section: 0) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(_ item: Item, withAnimation animation: SpotsAnimation, completion: Completion) {
    guard let index = component.items.index(where: { $0 == item })
      else { completion?(); return }

    component.items.remove(at: index)

    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.collectionView else { completion?(); return }
      collectionView.delete([index]) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(_ item: [Item], withAnimation animation: SpotsAnimation, completion: Completion) {
    var indexPaths = [Int]()
    let count = component.items.count

    for (index, item) in items.enumerated() {
      indexPaths.append(count + index)
      component.items.append(item)
    }

    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.collectionView else { completion?(); return }
      collectionView.delete(indexPaths) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(_ index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {
    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.collectionView else { completion?(); return }
      self?.component.items.remove(at: index)
      collectionView.delete([index]) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(_ indexes: [Int], withAnimation animation: SpotsAnimation, completion: Completion) {
    Dispatch.mainQueue { [weak self] in
      indexes.forEach { self?.component.items.remove(at: $0) }
      guard let collectionView = self?.collectionView else { completion?(); return }
      collectionView.delete(indexes) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: SpotsAnimation, updateDataSource: () -> Void, completion: Completion) {
    guard !changes.updates.isEmpty else {
      collectionView.process((insertions: changes.insertions, reloads: changes.reloads, deletions: changes.deletions), updateDataSource: updateDataSource, completion: completion)
      return
    }

    collectionView.process((insertions: changes.insertions, reloads: changes.reloads, deletions: changes.deletions), updateDataSource: updateDataSource) {

      for index in changes.updates {
        guard let item = self.item(at: index) else { continue }
        self.update(item, index: index, withAnimation: animation, completion: completion)
      }
    }
  }

  public func reload(_ indexes: [Int]?, withAnimation animation: SpotsAnimation, completion: Completion) {
    Dispatch.mainQueue { [weak self] in
      guard let collectionView = self?.collectionView else { completion?(); return }
      if let indexes = indexes, animation != .none {
        collectionView.reload(indexes) {
          self?.refreshHeight(completion)
        }
      } else {
        collectionView.reloadData()
        self?.setup(collectionView.frame.size)
        completion?()
      }
    }
  }

  public func refreshHeight(_ completion: (() -> Void)? = nil) {
    Dispatch.delay(for: 0.2) { [weak self] in
      guard let weakSelf = self, let collectionView = self?.collectionView else { return; completion?() }
      weakSelf.setup(CGSize(width: collectionView.frame.width, height: weakSelf.computedHeight ))
      completion?()
    }
  }
}
