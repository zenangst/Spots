import Cocoa
import Brick

extension ListAdapter {

  public func ui<T>(atIndex index: Int) -> T? {
    return spot.tableView.rowView(atRow: index, makeIfNecessary: false) as? T
  }

  public func append(_ item: Item, withAnimation animation: SpotsAnimation, completion: Completion) {
    let count = spot.component.items.count
    spot.component.items.append(item)
    spot.configureItem(count, usesViewSize: true)

    Dispatch.mainQueue { [weak self] in
      guard let tableView = self?.spot.tableView else { completion?(); return }
      tableView.insert([count], animation: animation.tableViewAnimation) {
        self?.spot.setup(tableView.frame.size)
        completion?()
      }
    }
  }
  public func append(_ items: [Item], withAnimation animation: SpotsAnimation, completion: Completion) {
    var indexes = [Int]()
    let count = spot.component.items.count

    spot.component.items.append(contentsOf: items)

    items.enumerated().forEach {
      let index = count + $0.offset
      indexes.append(index)
      spot.configureItem(index, usesViewSize: true)
    }

    Dispatch.mainQueue { [weak self] in
      guard let tableView = self?.spot.tableView else { completion?(); return }
      tableView.insert(indexes, animation: animation.tableViewAnimation) {
        self?.spot.layout(tableView.frame.size)
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
      guard let tableView = self?.spot.tableView else { completion?(); return }
      tableView.insert(indexes, animation: animation.tableViewAnimation) {
        self?.refreshHeight()
      }
    }
  }

  public func insert(_ item: Item, index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {
    spot.component.items.insert(item, at: index)

    Dispatch.mainQueue { [weak self] in
      guard let tableView = self?.spot.tableView else { completion?(); return }
      tableView.insert([index], animation: animation.tableViewAnimation) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func update(_ item: Item, index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {
    spot.items[index] = item

    Dispatch.mainQueue { [weak self] in
      guard let tableView = self?.spot.tableView else { completion?(); return }
      tableView.reload([index], section: 0, animation: animation.tableViewAnimation) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(_ item: Item, withAnimation animation: SpotsAnimation, completion: Completion) {
    guard let index = spot.component.items.index(where: { $0 == item })
      else { completion?(); return }

    spot.component.items.remove(at: index)

    Dispatch.mainQueue { [weak self] in
      guard let tableView = self?.spot.tableView else { completion?(); return }
      tableView.delete([index], animation: animation.tableViewAnimation) {
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
      guard let tableView = self?.spot.tableView else { completion?(); return }
      tableView.delete(indexPaths, animation: animation.tableViewAnimation) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(_ index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {
    Dispatch.mainQueue { [weak self] in
      guard let tableView = self?.spot.tableView else { completion?(); return }
      self?.spot.component.items.remove(at: index)
      tableView.delete([index], animation: animation.tableViewAnimation) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(_ indexes: [Int], withAnimation animation: SpotsAnimation, completion: Completion) {
    Dispatch.mainQueue { [weak self] in
      indexes.forEach { self?.spot.component.items.remove(at: $0) }
      guard let tableView = self?.spot.tableView else { completion?(); return }
      tableView.delete(indexes, animation: animation.tableViewAnimation) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: SpotsAnimation, updateDataSource: () -> Void, completion: Completion) {
    guard !changes.updates.isEmpty else {
      spot.tableView.process((insertions: changes.insertions, reloads: changes.reloads, deletions: changes.deletions), updateDataSource: updateDataSource, completion: completion)
      return
    }

    spot.tableView.process((insertions: changes.insertions, reloads: changes.reloads, deletions: changes.deletions), updateDataSource: updateDataSource) {

      for index in changes.updates {
        guard let item = self.spot.item(index) else { continue }
        self.spot.update(item, index: index, withAnimation: animation, completion: completion)
      }
    }
  }

  public func reload(_ indexes: [Int]?, withAnimation animation: SpotsAnimation, completion: Completion) {
    Dispatch.mainQueue { [weak self] in
      guard let tableView = self?.spot.tableView else { completion?(); return }
      if let indexes = indexes, animation != .none {
        tableView.reload(indexes, animation: animation.tableViewAnimation) {
          self?.refreshHeight(completion)
        }
      } else {
        tableView.reloadData()
        self?.refreshHeight(completion)
      }
    }
  }

  public func refreshHeight(_ completion: (() -> Void)? = nil) {
    spot.layout(CGSize(width: spot.tableView.frame.width, height: spot.spotHeight() ))
    completion?()
  }
}

extension ListAdapter: NSTableViewDataSource {

  public func numberOfRows(in tableView: NSTableView) -> Int {
    return spot.component.items.count
  }

  public func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
    return false
  }
}

extension ListAdapter: NSTableViewDelegate {

  public func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
    guard let viewModel = spot.item(row), row > -1 && row < spot.component.items.count
      else {
        return false
    }

    if spot.component.meta(ListSpot.Key.doubleAction, type: Bool.self) != true {
      spot.spotsDelegate?.spotDidSelectItem(spot, item: viewModel)
    }

    return true
  }

  public func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
    spot.component.size = CGSize(
      width: tableView.frame.width,
      height: tableView.frame.height)

    let height = row < spot.component.items.count ? spot.item(row)?.size.height ?? 0 : 1.0

    if height == 0 { return 1.0 }

    return height
  }

  public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
    guard row >= 0 && row < spot.component.items.count else { return nil }

    let reuseIdentifier = spot.identifier(row)
    guard let cachedView = type(of: spot).views.make(reuseIdentifier) else { return nil }

    var view: View? = nil
    if let type = cachedView.type {
      switch type {
      case .regular:
        view = cachedView.view
      case .nib:
        view = tableView.make(withIdentifier: reuseIdentifier, owner: nil)
      }
    }

    (view as? SpotConfigurable)?.configure(&spot.component.items[row])
    (view as? NSTableRowView)?.identifier = reuseIdentifier

    return view as? NSTableRowView
  }

  public func tableView(_ tableView: NSTableView, willDisplayCell cell: Any, for tableColumn: NSTableColumn?, row: Int) {}

  public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    return nil
  }
}
