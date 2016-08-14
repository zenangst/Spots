import Brick
import UIKit
import Sugar

extension ListAdapter {
  /**
   - Parameter item: The view model that you want to append
   - Parameter animation: The animation that should be used
   - Parameter completion: Completion
   */
  public func append(item: ViewModel, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    let count = spot.component.items.count
    spot.component.items.append(item)

    dispatch { [weak self] in
      self?.spot.tableView.insert([count], animation: animation.tableViewAnimation)
      completion?()
    }

    spot.configureItem(count)
  }

  /**
   - Parameter item: A collection of view models that you want to insert
   - Parameter animation: The animation that should be used
   - Parameter completion: Completion
   */
  public func append(items: [ViewModel], withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    var indexes = [Int]()
    let count = spot.component.items.count

    spot.component.items.appendContentsOf(items)

    items.enumerate().forEach {
      indexes.append(count + $0.index)
      spot.configureItem(count + $0.index)
    }

    dispatch { [weak self] in
      self?.spot.tableView.insert(indexes, animation: animation.tableViewAnimation)
      completion?()
    }
  }

  /**
   - Parameter item: The view model that you want to insert
   - Parameter index: The index where the new ViewModel should be inserted
   - Parameter animation: The animation that should be used
   - Parameter completion: Completion
   */
  public func insert(item: ViewModel, index: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    spot.component.items.insert(item, atIndex: index)

    dispatch { [weak self] in
      self?.spot.tableView.insert([index], animation: animation.tableViewAnimation)
      completion?()
    }
  }

  /**
   - Parameter item: A collection of view model that you want to prepend
   - Parameter animation: The animation that should be used
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func prepend(items: [ViewModel], withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    var indexes = [Int]()

    spot.component.items.insertContentsOf(items, at: 0)

    dispatch { [weak self, spot = spot] in
      items.enumerate().forEach {
        let index = items.count - 1 - $0.index
        indexes.append(index)
        spot.configureItem(index)
      }

      self?.spot.tableView.insert(indexes, animation: animation.tableViewAnimation)
      completion?()
    }
  }

  /**
   - Parameter item: The view model that you want to remove
   - Parameter animation: The animation that should be used
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func delete(item: ViewModel, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    guard let index = spot.component.items.indexOf({ $0 == item })
      else { completion?(); return }

    spot.component.items.removeAtIndex(index)

    dispatch { [weak self] in
      self?.spot.tableView.delete([index], animation: animation.tableViewAnimation)
      completion?()
    }
  }

  /**
   - Parameter item: A collection of view models that you want to delete
   - Parameter animation: The animation that should be used
   - Parameter completion: A completion closure that is executed in the main queue
   */
  public func delete(items: [ViewModel], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    var indexPaths = [Int]()
    let count = spot.component.items.count

    for (index, item) in items.enumerate() {
      indexPaths.append(count + index)
      spot.component.items.append(item)
    }

    dispatch { [weak self] in
      self?.spot.tableView.delete(indexPaths, animation: animation.tableViewAnimation)
      completion?()
    }
  }

  /**
   - Parameter index: The index of the view model that you want to remove
   - Parameter animation: The animation that should be used
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  public func delete(index: Int, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    dispatch { [weak self] in
      self?.spot.component.items.removeAtIndex(index)
      self?.spot.tableView.delete([index], animation: animation.tableViewAnimation)
      completion?()
    }
  }

  /**
   - Parameter indexes: An array of indexes that you want to remove
   - Parameter animation: The animation that should be used
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been removed
   */
  public func delete(indexes: [Int], withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    dispatch { [weak self] in
      indexes.forEach { self?.spot.component.items.removeAtIndex($0) }
      self?.spot.tableView.delete(indexes, section: 0, animation: animation.tableViewAnimation)
      completion?()
    }
  }

  /**
   - Parameter item: The new update view model that you want to update at an index
   - Parameter index: The index of the view model, defaults to 0
   - Parameter animation: The animation that should be used
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been updated
   */
  public func update(item: ViewModel, index: Int = 0, withAnimation animation: SpotsAnimation = .None, completion: Completion = nil) {
    let oldItem = spot.items[index]

    spot.items[index] = item
    spot.configureItem(index)

    let newItem = spot.items[index]
    let indexPath = NSIndexPath(forRow: index, inSection: 0)

    if newItem.kind != oldItem.kind || newItem.size.height != oldItem.size.height {
      if let cell = spot.tableView.cellForRowAtIndexPath(indexPath) as? SpotConfigurable {
        spot.tableView.beginUpdates()
        cell.configure(&spot.items[index])
        spot.tableView.endUpdates()
      } else {
        spot.tableView.reload([index], section: 0, animation: animation.tableViewAnimation)
      }
    } else if let cell = spot.tableView.cellForRowAtIndexPath(indexPath) as? SpotConfigurable {
      cell.configure(&spot.items[index])
    }

    completion?()
  }

  /**
   - Parameter indexes: An array of integers that you want to reload, default is nil
   - Parameter animated: Perform reload animation
   - Parameter completion: A completion closure that is executed in the main queue when the view model has been reloaded
   */
  public func reload(indexes: [Int]? = nil, withAnimation animation: SpotsAnimation = .Automatic, completion: Completion = nil) {
    spot.refreshIndexes()

    if let indexes = indexes {
      indexes.forEach { index  in
        spot.configureItem(index)
      }
    } else {
      for (index, _) in spot.component.items.enumerate() {
        spot.configureItem(index)
      }
    }

    animation != .None ? spot.tableView.reloadSection(0, animation: animation.tableViewAnimation) : spot.tableView.reloadData()
    UIView.setAnimationsEnabled(true)
    completion?()
  }
}

/**
 A UITableViewDelegate extension on ListAdapter
 */
extension ListAdapter: UITableViewDelegate {

  /**
   Asks the delegate for the height to use for the header of a particular section.

   - Parameter tableView	: The table-view object requesting this information.
   - Parameter heightForHeaderInSection: An index number identifying a section of tableView.
   - Returns: Returns the `headerHeight` found in `component.meta`, otherwise 0.0.
   **/
  public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return spot.component.meta(ListSpot.Key.headerHeight, 0.0)
  }

  /**
   Asks the data source for the title of the header of the specified section of the table view.

   - Parameter tableView	: The table-view object asking for the title.
   - Parameter section: An index number identifying a section of tableView.
   - Returns: A string to use as the title of the section header. Will return `nil` if title is not present on Component
   **/
  public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return spot.component.title.isPresent ? spot.component.title : nil
  }

  /**
   Tells the delegate that the specified row is now selected.

   - Parameter tableView	: A table-view object informing the delegate about the new row selection.
   - Parameter indexPath: An index path locating the new selected row in tableView.
   **/
  public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    if let item = spot.item(indexPath) {
      spot.spotsDelegate?.spotDidSelectItem(spot, item: item)
    }
  }

  /**
   Asks the delegate for a view object to display in the header of the specified section of the table view.

   - Parameter tableView	: The table-view object asking for the view object.
   - Parameter section: An index number identifying a section of tableView.
   - Returns: A view object to be displayed in the header of section based on the kind of the ListSpot and registered headers.
   **/
  public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard spot.component.meta(ListSpot.Key.headerHeight, type: CGFloat.self) != 0.0 else { return nil }

    let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(spot.component.kind)
    view?.height = spot.component.meta(ListSpot.Key.headerHeight, 0.0)
    view?.width = spot.tableView.width
    (view as? Componentable)?.configure(spot.component)

    return view
  }

  /**
   Asks the delegate for the height to use for a row in a specified location.

   - Parameter tableView: The table-view object requesting this information.
   - Parameter indexPath: An index path that locates a row in tableView.
   - Returns:  A nonnegative floating-point value that specifies the height (in points) that row should be based on the view model height, defaults to 0.0.
   */
  public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    spot.component.size = CGSize(
      width: tableView.width,
      height: tableView.height)

    return spot.item(indexPath)?.size.height ?? 0
  }
}

// MARK: - UITableViewDataSource

extension ListAdapter: UITableViewDataSource {

  /**
   Tells the data source to return the number of rows in a given section of a table view. (required)

   - Parameter tableView	: The table-view object requesting this information.
   - Parameter section: An index number identifying a section in tableView.
   - Returns: The number of rows in section.
   */
  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return spot.component.items.count
  }

  /**
   Asks the data source for a cell to insert in a particular location of the table view. (required)

   - Parameter tableView	: A table-view object requesting the cell.
   indexPath
   - Parameter indexPath: An index path locating a row in tableView.
   - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. Will return the default table view cell for the current component based of kind.
   */
  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.item < spot.component.items.count {
      spot.component.items[indexPath.item].index = indexPath.row
    }

    let reuseIdentifier = spot.identifier(indexPath)
    let cell: UITableViewCell = tableView
      .dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)

    #if os(iOS)
      cell.optimize()
    #endif

    if let cell = cell as? SpotConfigurable where indexPath.item < spot.component.items.count {
      cell.configure(&spot.component.items[indexPath.item])
      if spot.component.items[indexPath.item].size.height == 0.0 {
        spot.component.items[indexPath.item].size = cell.size
      }

      spot.configure?(cell)
    }

    return cell
  }
}
