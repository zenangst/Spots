// swiftlint:disable empty_count large_tuple
import Cocoa

extension NSTableView: UserInterface {

  public var visibleViews: [View] {
    let rows = self.rows(in: visibleRect)
    var views = [View]()

    for row in rows.location..<rows.length-rows.location {
      guard let view = rowView(atRow: row, makeIfNecessary: false) else {
        continue
      }

      views.append(resolveVisibleView(view))
    }

    return views
  }

  public static var compositeIdentifier: String {
    return "list-composite"
  }

  public func register() {
    Configuration.register(view: ListWrapper.self, identifier: TableView.compositeIdentifier)
  }

  public func view<T>(at index: Int) -> T? {
    let view = rowView(atRow: index, makeIfNecessary: true)

    switch view {
    case let view as ListWrapper:
      return view.wrappedView as? T
    default:
      return view as? T
    }
  }

  public func insert(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: (() -> Void)? = nil) {
    guard let dataSource = dataSource else {
      assertionFailure("Data source could not be resolved.")
      return
    }

    let numberOfRows = dataSource.numberOfRows!(in: self) - indexes.count
    let algorithm = MoveAlgorithm()
    let movedItems = algorithm.calculateMoveForInsertedIndexes(indexes, numberOfItems: numberOfRows)

    var indexSet = IndexSet()
    indexes.forEach {
      indexSet.insert($0)
    }

    performUpdates({
      insertRows(at: indexSet, withAnimation: animation.tableViewAnimation)
      for (from, to) in movedItems {
        moveRow(at: from, to: to)
      }
    }, completion: completion)

  }

  public func reload(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: (() -> Void)? = nil) {
    guard let component = (dataSource as? DataSource)?.component else {
      return
    }

    /** Manually handle reloading of the cell as reloadDataForRowIndexes does not seems to work with view based table views
     - "For NSView-based table views, this method drops the view-cells in the table row, but not the NSTableRowView instances."
     */
    var indexSet = IndexSet()
    indexes.forEach { indexSet.insert($0) }

    performUpdates({
      removeRows(at: indexSet, withAnimation: animation.tableViewAnimation)
      insertRows(at: indexSet, withAnimation: animation.tableViewAnimation)
    })

    for index in indexes {
      guard let view = rowView(atRow: index, makeIfNecessary: false) else {
        continue
      }

      var item = component.model.items[index]
      configure(view: view, with: &item)
      component.model.items[index] = item
    }

    completion?()
  }

  public func delete(_ indexes: [Int], withAnimation animation: Animation = .automatic, completion: (() -> Void)? = nil) {
    guard let dataSource = dataSource else {
      assertionFailure("Data source could not be resolved.")
      return
    }

    var indexSet = IndexSet()
    let numberOfRows = dataSource.numberOfRows!(in: self)
    let algorithm = MoveAlgorithm()
    let movedItems = algorithm.calculateMoveForDeletedIndexes(indexes, numberOfItems: numberOfRows)
    indexes.forEach { indexSet.insert($0) }

    performUpdates({
      for (from, to) in movedItems {
        moveRow(at: from, to: to)
      }
      removeRows(at: indexSet, withAnimation: animation.tableViewAnimation)
    }, completion: completion)
  }

  public func processChanges(_ changes: Changes,
                             withAnimation animation: Animation = .automatic,
                             updateDataSource: () -> Void,
                             completion: ((()) -> Void)? = nil) {
    guard let component = (dataSource as? DataSource)?.component else {
      return
    }

    let insertionsSets = NSMutableIndexSet()
    changes.insertions.forEach { insertionsSets.add($0) }
    let reloadSets = NSMutableIndexSet()
    changes.reloads.forEach { reloadSets.add($0) }
    let deletionSets = NSMutableIndexSet()
    changes.deletions.forEach { deletionSets.add($0) }

    updateDataSource()

    if insertionsSets.count > 0 &&
      reloadSets.count > 0 &&
      deletionSets.count > 0 &&
      changes.moved.isEmpty &&
      changes.childUpdates.isEmpty {
      completion?()
      return
    }

    beginUpdates()
    removeRows(at: deletionSets as IndexSet, withAnimation: animation.tableViewAnimation)
    insertRows(at: insertionsSets as IndexSet, withAnimation: animation.tableViewAnimation)

    for move in changes.moved {
      moveRow(at: move.key, to: move.value)
    }

    for index in reloadSets {
      guard let view = rowView(atRow: index, makeIfNecessary: false) else {
        continue
      }

      guard var item = component.item(at: index) else {
        continue
      }

      configure(view: view, with: &item)
      component.model.items[index] = item
    }

    completion?()
    endUpdates()
  }

  public func reloadSection(_ section: Int, withAnimation animation: Animation, completion: (() -> Void)?) {
    reloadData()
    completion?()
  }

  public func reloadDataSource() {
    reloadData()
  }

  /// Perform batch updates on the data source.
  ///
  /// - Parameters:
  ///   - updateClosure: An update closure that is invoked inbetween `beginUpdates` and `endUpdates`.
  ///   - completion: An optional completion closure that is invoked after `endUpdates.
  public func performUpdates( _ updateClosure: () -> Void, completion: (() -> Void)? = nil) {
    beginUpdates()
    updateClosure()
    endUpdates()
    completion?()
  }

  fileprivate func configure(view: View, with item: inout Item) {
    switch view {
    case let wrapper as Wrappable:
      (wrapper.wrappedView as? ItemConfigurable)?.configure(with: item)
    case let itemConfigurable as ItemConfigurable:
      itemConfigurable.configure(with: item)
    default:
      break
    }
  }
}
