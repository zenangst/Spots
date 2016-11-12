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
    let operation = SpotOperation(completion) { [weak self] completion in
      guard let weakSelf = self else { completion(); return }

      let count = weakSelf.component.items.count
      weakSelf.component.items.append(item)
      weakSelf.configureItem(at: count, usesViewSize: true)

      Dispatch.mainQueue { [weak self] in
        guard let tableView = self?.tableView else { completion(); return }
        tableView.insert([count], withAnimation: animation.tableViewAnimation) {
          self?.setup(tableView.frame.size)
          completion()
        }
      }
    }

    operationQueue.addOperation(operation)
  }
  public func append(_ items: [Item], withAnimation animation: Animation, completion: Completion) {
    let operation = SpotOperation(completion) { [weak self] completion in
      guard let weakSelf = self else { completion(); return }
      var indexes = [Int]()
      let count = weakSelf.component.items.count

      weakSelf.component.items.append(contentsOf: items)

      items.enumerated().forEach {
        let index = count + $0.offset
        indexes.append(index)
        weakSelf.configureItem(at: index, usesViewSize: true)
      }

      Dispatch.mainQueue { [weak self] in
        guard let tableView = self?.tableView else { completion(); return }
        tableView.insert(indexes, withAnimation: animation.tableViewAnimation) {
          self?.layout(tableView.frame.size)
          completion()
        }
      }
    }
    operationQueue.addOperation(operation)
  }

  public func prepend(_ items: [Item], withAnimation animation: Animation, completion: Completion) {
    let operation = SpotOperation(completion) { [weak self] completion in
      guard let weakSelf = self else { completion(); return }
      var indexes = [Int]()

      weakSelf.component.items.insert(contentsOf: items, at: 0)

      items.enumerated().forEach {
        indexes.append(items.count - 1 - $0.offset)
      }

      Dispatch.mainQueue { [weak self] in
        guard let tableView = self?.tableView else { completion(); return }
        tableView.insert(indexes, withAnimation: animation.tableViewAnimation) {
          self?.refreshHeight(completion)
        }
      }
    }
    operationQueue.addOperation(operation)
  }

  public func reload(_ indexes: [Int]?, withAnimation animation: Animation, completion: Completion) {
    let operation = SpotOperation(completion) { completion in
      Dispatch.mainQueue { [weak self] in
        guard let tableView = self?.tableView else { completion(); return }

        if let indexes = indexes {
          tableView.reload(indexes, section: 0, withAnimation: animation.tableViewAnimation) {
            self?.sanitize { completion() }
          }
        } else {
          tableView.reloadData()
          self?.sanitize { completion() }
        }
      }
    }

    operationQueue.addOperation(operation)
  }

  public func insert(_ item: Item, index: Int, withAnimation animation: Animation, completion: Completion) {
    let operation = SpotOperation(completion) { [weak self] completion in
      guard let weakSelf = self else { completion(); return }

      weakSelf.component.items.insert(item, at: index)

      Dispatch.mainQueue { [weak self] in
        guard let tableView = self?.tableView else { completion(); return }
        tableView.insert([index], withAnimation: animation.tableViewAnimation) {
          self?.sanitize { completion() }
        }
      }
    }
    operationQueue.addOperation(operation)
  }

  public func update(_ item: Item, index: Int, withAnimation animation: Animation, completion: Completion) {
    let operation = SpotOperation(completion) { [weak self] completion in
      guard let weakSelf = self else {
        completion()
        return
      }

      weakSelf.items[index] = item

      Dispatch.mainQueue { [weak self] in
        guard let tableView = self?.tableView else { completion(); return }
        tableView.reload([index], section: 0, withAnimation: animation.tableViewAnimation) {
          self?.sanitize { completion() }
        }
      }
    }

    operationQueue.addOperation(operation)
  }

  public func delete(_ item: Item, withAnimation animation: Animation, completion: Completion) {
    let operation = SpotOperation(completion) { [weak self] completion in
      guard let weakSelf = self,
        let index = weakSelf.component.items.index(where: { $0 == item })
        else {
          completion()
          return
      }

      weakSelf.component.items.remove(at: index)

      Dispatch.mainQueue { [weak self] in
        guard let tableView = self?.tableView else { completion(); return }
        tableView.delete([index], withAnimation: animation.tableViewAnimation) {
          self?.sanitize { completion() }
        }
      }
    }
    operationQueue.addOperation(operation)
  }

  public func delete(_ item: [Item], withAnimation animation: Animation, completion: Completion) {
    let operation = SpotOperation(completion) { [weak self] completion in
      guard let weakSelf = self else {
        completion()
        return
      }

      var indexPaths = [Int]()
      let count = weakSelf.component.items.count

      for (index, item) in weakSelf.items.enumerated() {
        indexPaths.append(count + index)
        weakSelf.component.items.append(item)
      }

      Dispatch.mainQueue { [weak self] in
        guard let tableView = self?.tableView else { completion(); return }
        tableView.delete(indexPaths, withAnimation: animation.tableViewAnimation) {
          self?.sanitize { completion() }
        }
      }
    }

    operationQueue.addOperation(operation)
  }

  public func delete(_ index: Int, withAnimation animation: Animation, completion: Completion) {
    let operation = SpotOperation(completion) { completion in
      Dispatch.mainQueue { [weak self] in
        guard let tableView = self?.tableView else { completion(); return }
        self?.component.items.remove(at: index)
        tableView.delete([index], withAnimation: animation.tableViewAnimation) {
          self?.sanitize { completion() }
        }
      }
    }

    operationQueue.addOperation(operation)
  }

  public func delete(_ indexes: [Int], withAnimation animation: Animation, completion: Completion) {
    let operation = SpotOperation(completion) { completion in
      Dispatch.mainQueue { [weak self] in
        indexes.forEach { self?.component.items.remove(at: $0) }
        guard let tableView = self?.tableView else { completion(); return }
        tableView.delete(indexes, withAnimation: animation.tableViewAnimation) {
          self?.sanitize { completion() }
        }
      }
    }

    operationQueue.addOperation(operation)
  }

  public func refreshHeight(_ completion: (() -> Void)? = nil) {
    layout(CGSize(width: tableView.frame.width, height: computedHeight ))
    completion?()
  }
}
