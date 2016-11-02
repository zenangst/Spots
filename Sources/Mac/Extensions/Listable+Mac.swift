import Cocoa
import Brick

extension Listable {

  public var responder: NSResponder {
    return tableView
  }

  public var nextResponder: NSResponder? {
    get {
      return tableView.nextResponder
    }
    set {
      tableView.nextResponder = newValue
    }
  }

  func configureLayout(_ component: Component) {
    let top: CGFloat = component.meta("inset-top", 0.0)
    let left: CGFloat = component.meta("inset-left", 0.0)
    let bottom: CGFloat = component.meta("inset-bottom", 0.0)
    let right: CGFloat = component.meta("inset-right", 0.0)

    render().contentInsets = EdgeInsets(top: top, left: left, bottom: bottom, right: right)
  }

  public func deselect() {
    tableView.deselectAll(nil)
  }

  @discardableResult public func selectFirst() -> Self {
    guard let item = item(at: 0), !component.items.isEmpty else { return self }
    tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
    delegate?.didSelect(item: item, in: self)

    return self
  }

  public func ui<T>(at index: Int) -> T? {
    return tableView.rowView(atRow: index, makeIfNecessary: false) as? T
  }

  public func append(_ item: Item, withAnimation animation: Animation, completion: Completion) {
    let count = component.items.count
    component.items.append(item)
    configureItem(at: count, usesViewSize: true)

    Dispatch.mainQueue { [weak self] in
      guard let tableView = self?.tableView else { completion?(); return }
      tableView.insert([count], animation: animation.tableViewAnimation) {
        self?.setup(tableView.frame.size)
        completion?()
      }
    }
  }
  public func append(_ items: [Item], withAnimation animation: Animation, completion: Completion) {
    var indexes = [Int]()
    let count = component.items.count

    component.items.append(contentsOf: items)

    items.enumerated().forEach {
      let index = count + $0.offset
      indexes.append(index)
      configureItem(at: index, usesViewSize: true)
    }

    Dispatch.mainQueue { [weak self] in
      guard let tableView = self?.tableView else { completion?(); return }
      tableView.insert(indexes, animation: animation.tableViewAnimation) {
        self?.layout(tableView.frame.size)
        completion?()
      }
    }
  }

  public func prepend(_ items: [Item], withAnimation animation: Animation, completion: Completion) {
    var indexes = [Int]()

    component.items.insert(contentsOf: items, at: 0)

    items.enumerated().forEach {
      indexes.append(items.count - 1 - $0.offset)
    }

    Dispatch.mainQueue { [weak self] in
      guard let tableView = self?.tableView else { completion?(); return }
      tableView.insert(indexes, animation: animation.tableViewAnimation) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func insert(_ item: Item, index: Int, withAnimation animation: Animation, completion: Completion) {
    component.items.insert(item, at: index)

    Dispatch.mainQueue { [weak self] in
      guard let tableView = self?.tableView else { completion?(); return }
      tableView.insert([index], animation: animation.tableViewAnimation) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func update(_ item: Item, index: Int, withAnimation animation: Animation, completion: Completion) {
    items[index] = item

    Dispatch.mainQueue { [weak self] in
      guard let tableView = self?.tableView else { completion?(); return }
      tableView.reload([index], section: 0, animation: animation.tableViewAnimation) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(_ item: Item, withAnimation animation: Animation, completion: Completion) {
    guard let index = component.items.index(where: { $0 == item })
      else { completion?(); return }

    component.items.remove(at: index)

    Dispatch.mainQueue { [weak self] in
      guard let tableView = self?.tableView else { completion?(); return }
      tableView.delete([index], animation: animation.tableViewAnimation) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(_ item: [Item], withAnimation animation: Animation, completion: Completion) {
    var indexPaths = [Int]()
    let count = component.items.count

    for (index, item) in items.enumerated() {
      indexPaths.append(count + index)
      component.items.append(item)
    }

    Dispatch.mainQueue { [weak self] in
      guard let tableView = self?.tableView else { completion?(); return }
      tableView.delete(indexPaths, animation: animation.tableViewAnimation) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(_ index: Int, withAnimation animation: Animation, completion: Completion) {
    Dispatch.mainQueue { [weak self] in
      guard let tableView = self?.tableView else { completion?(); return }
      self?.component.items.remove(at: index)
      tableView.delete([index], animation: animation.tableViewAnimation) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(_ indexes: [Int], withAnimation animation: Animation, completion: Completion) {
    Dispatch.mainQueue { [weak self] in
      indexes.forEach { self?.component.items.remove(at: $0) }
      guard let tableView = self?.tableView else { completion?(); return }
      tableView.delete(indexes, animation: animation.tableViewAnimation) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: Animation, updateDataSource: () -> Void, completion: Completion) {
    guard !changes.updates.isEmpty else {
      tableView.process((insertions: changes.insertions, reloads: changes.reloads, deletions: changes.deletions), updateDataSource: updateDataSource, completion: completion)
      return
    }

    tableView.process((insertions: changes.insertions, reloads: changes.reloads, deletions: changes.deletions), updateDataSource: updateDataSource) {

      for index in changes.updates {
        guard let item = self.item(at: index) else { continue }
        self.update(item, index: index, withAnimation: animation, completion: completion)
      }
    }
  }

  public func reload(_ indexes: [Int]?, withAnimation animation: Animation, completion: Completion) {
    Dispatch.mainQueue { [weak self] in
      guard let tableView = self?.tableView else { completion?(); return }
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
    layout(CGSize(width: tableView.frame.width, height: computedHeight ))
    completion?()
  }
}
