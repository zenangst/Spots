import Cocoa

extension NSCollectionView: UserInterface {

  public func view<T>(at index: Int) -> T? {
    return item(at: index) as? T
  }

  /**
   A convenience method for performing inserts on a UICollectionView
   - parameter indexes: A collection integers
   - parameter section: The section you want to update
   - parameter completion: A completion block for when the updates are done
   **/
  public func insert(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { IndexPath(item: $0, section: 0) }
    let set = Set<IndexPath>(indexPaths)

    performBatchUpdates({ [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.insertItems(at: set as Set<IndexPath>)
    }) { _ in
      completion?()
    }
  }

  /**
   A convenience method for performing updates on a UICollectionView
   - parameter indexes: A collection integers
   - parameter section: The section you want to update
   - parameter completion: A completion block for when the updates are done
   **/
  public func reload(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { IndexPath(item: $0, section: 0) }
    let set = Set<IndexPath>(indexPaths)

    //UIView.performWithoutAnimation {
      self.reloadItems(at: set as Set<IndexPath>)
      completion?()
    //}
  }

  /**
   A convenience method for performing deletions on a UICollectionView
   - parameter indexes: A collection integers
   - parameter section: The section you want to update
   - parameter completion: A completion block for when the updates are done
   **/
  public func delete(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: (() -> Void)? = nil) {
    let indexPaths = indexes.map { IndexPath(item: $0, section: 0) }
    let set = Set<IndexPath>(indexPaths)

    performBatchUpdates({ [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.deleteItems(at: set as Set<IndexPath>)
    }) { _ in
      completion?()
    }
  }

  public func process(_ changes: (insertions: [Int], reloads: [Int], deletions: [Int], childUpdates: [Int]),
                      withAnimation animation: Animation = .automatic,
                      updateDataSource: () -> Void,
                      completion: ((()) -> Void)? = nil) {
    let deletionSets = Set<IndexPath>(changes.deletions
      .map { IndexPath(item: $0, section: 0) })
    let insertionsSets = Set<IndexPath>(changes.insertions
      .map { IndexPath(item: $0, section: 0) })
    let reloadSets = Set<IndexPath>(changes.reloads
      .map { IndexPath(item: $0, section: 0) })

    performBatchUpdates({ [weak self] in
      self?.deleteItems(at: deletionSets)
      self?.insertItems(at: insertionsSets)
      self?.reloadItems(at: reloadSets)
      }) { _ in
        completion?()
    }
  }

  public func reloadDataSource() {
    reloadData()
  }

  /**
   A convenience method for reloading a section
   - parameter index: The section you want to update
   - parameter completion: A completion block for when the updates are done
   **/
  public func reloadSection(_ section: Int, withAnimation animation: Animation, completion: (() -> Void)?) {
    performBatchUpdates({ [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.reloadSections(IndexSet(integer: section))
    }) { _ in
      completion?()
    }
  }

  public func beginUpdates() {}
  public func endUpdates() {}
}
