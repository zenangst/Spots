import UIKit
import Tailor
import Sugar

public class FeedSpot: NSObject, Spotable {

  public static var cells = [String : UITableViewCell.Type]()
  public static var headers = [String : UIView.Type]()
  public static var defaultCell: UITableViewCell.Type = FeedSpotCell.self
  public static var configure: ((view: UITableView) -> Void)?

  public let itemHeight: CGFloat = 44
  public let headerHeight: CGFloat = 44
  
  public var index = 0
  public var component: Component
  
  public weak var sizeDelegate: SpotSizeDelegate?
  public weak var spotDelegate: SpotsDelegate?

  public var cachedCells = [String : Itemble]()
  private var lastContentOffset = CGPoint()
  private var fetching = false

  public lazy var tableView: UITableView = { [unowned self] in
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.frame.size.width = UIScreen.mainScreen().bounds.width
    tableView.autoresizingMask = [.FlexibleWidth, .FlexibleRightMargin, .FlexibleLeftMargin]
    tableView.autoresizesSubviews = true
    tableView.rowHeight = UITableViewAutomaticDimension

    return tableView
  }()

  public required init(component: Component) {
    self.component = component
    super.init()

    let items = component.items
    for (index, item) in items.enumerate() {
      let componentCellClass = FeedSpot.cells[item.kind] ?? FeedSpot.defaultCell
      if cache(component.items[index].kind) {
        cachedCells[item.kind]!.configure(&self.component.items[index])
      } else {
        if let cell = componentCellClass.init() as? Itemble {
          cell.configure(&self.component.items[index])
          cachedCells[item.kind] = cell
        }
      }
    }
  }

  public func setup() {
    if component.size == nil {
      var newHeight = component.items.reduce(0, combine: { $0 + $1.size.height })
      if !component.title.isEmpty { newHeight += headerHeight }
      tableView.frame.size.width = UIScreen.mainScreen().bounds.width
      tableView.frame.size.height = UIScreen.mainScreen().bounds.height - 64
      tableView.contentSize = CGSize(width: tableView.frame.width, height: newHeight - tableView.contentInset.top - tableView.contentInset.bottom)
    } else {
      tableView.scrollEnabled = false
    }

    FeedSpot.configure?(view: tableView)
  }

  private func cache(identifier: String) -> Bool {
    if !cellIsCached(identifier) {
      let componentCellClass = FeedSpot.cells[identifier] ?? FeedSpot.defaultCell
      tableView.registerClass(componentCellClass, forCellReuseIdentifier: component.items[index].kind)
      
      if let feedCell = componentCellClass.init() as? Itemble {
        cachedCells[identifier] = feedCell
      }
      return false
    } else {
      return true
    }
  }

  public func append(item: ListItem, completion: (() -> Void)? = nil) {
    cache(item.kind)

    var indexPaths = [NSIndexPath]()
    indexPaths.append(NSIndexPath(forRow: component.items.count, inSection: 0))
    component.items.append(item)

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      weakSelf.tableView.beginUpdates()
      weakSelf.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
      weakSelf.tableView.endUpdates()

      completion?()
    }
  }

  public func append(items: [ListItem], completion: (() -> Void)? = nil) {
    var indexPaths = [NSIndexPath]()
    let count = component.items.count

    for (index, item) in items.enumerate() {
      cache(item.kind)
      indexPaths.append(NSIndexPath(forRow: count + index, inSection: 0))
      component.items.append(item)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      weakSelf.tableView.beginUpdates()
      weakSelf.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
      weakSelf.tableView.endUpdates()

      completion?()
    }
  }

  public func delete(item: ListItem, completion: (() -> Void)? = nil) {
    var indexPaths = [NSIndexPath]()
    indexPaths.append(NSIndexPath(forRow: component.items.count, inSection: 0))
    component.items.append(item)

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      weakSelf.tableView.beginUpdates()
      weakSelf.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
      weakSelf.tableView.endUpdates()

      completion?()
    }
  }

  public func delete(items: [ListItem], completion: (() -> Void)? = nil) {
    var indexPaths = [NSIndexPath]()
    let count = component.items.count

    for (index, item) in items.enumerate() {
      indexPaths.append(NSIndexPath(forRow: count + index, inSection: 0))
      component.items.append(item)
    }

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      weakSelf.tableView.beginUpdates()
      weakSelf.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
      weakSelf.tableView.endUpdates()

      completion?()
    }
  }

  public func reload(indexes: [Int] = [], completion: (() -> Void)? = nil) {
    let items = component.items
    for (index, item) in items.enumerate() {
      cache(item.kind)
      let componentCellClass = FeedSpot.cells[item.kind] ?? FeedSpot.defaultCell
      tableView.registerClass(componentCellClass,
        forCellReuseIdentifier: component.items[index].kind)
      if let listCell = componentCellClass.init() as? Itemble {
        component.items[index].index = index
        listCell.configure(&component.items[index])
      }
    }
    
    tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
    completion?()
  }

  public func render() -> UIView {
    return tableView
  }

  public func layout(size: CGSize) {
    tableView.frame.size.width = size.width
    tableView.layoutIfNeeded()
  }
}

extension FeedSpot: UIScrollViewDelegate {

  public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    lastContentOffset = scrollView.contentOffset
  }

  public func scrollViewDidScroll(scrollView: UIScrollView) {
    let offset = scrollView.contentOffset
    let bounds = scrollView.bounds
    let size = scrollView.contentSize
    let inset = scrollView.contentInset
    let shouldFetch = offset.y + bounds.size.height - inset.bottom > size.height - headerHeight - itemHeight
      && size.height > bounds.size.height
      && !fetching


    if scrollView.contentOffset.y < 0.0 {
      sizeDelegate?.scrollToPreviousCell(component)
    } else if scrollView.contentOffset.y == 0.0 {
      tableView.scrollEnabled = true
    } else if scrollView.contentOffset.y >= tableView.contentSize.height + tableView.contentInset.bottom - tableView.bounds.height {
      sizeDelegate?.scrollToNextCell(component)
    } else if lastContentOffset.y > scrollView.contentOffset.y {
      sizeDelegate?.scrollToPreviousCell(component)
      lastContentOffset = CGPoint(x: 0, y: 0)
    }

    if shouldFetch && !fetching {
      fetching = true
      spotDelegate?.spotDidReachEnd {
        self.fetching = false
      }
    }
  }
}

extension FeedSpot: UITableViewDelegate {

  public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    spotDelegate?.spotDidSelectItem(self, item: component.items[indexPath.row])
  }

  public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    var newHeight = component.items.reduce(0, combine: { $0 + $1.size.height })

    if !component.title.isEmpty { newHeight += headerHeight }
    
    component.size = CGSize(width: tableView.frame.width, height: tableView.frame.height)
    sizeDelegate?.sizeDidUpdate()

    return component.items[indexPath.item].size.height
  }
}

extension FeedSpot: UITableViewDataSource {

  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return component.items.count
  }

  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    component.items[indexPath.item].index = indexPath.row

    let cell: UITableViewCell
    cell = tableView.dequeueReusableCellWithIdentifier(component.items[indexPath.item].kind, forIndexPath: indexPath)

    guard let itemable = cell as? Itemble else { return cell }
    
    itemable.configure(&component.items[indexPath.item])

    return cell
  }
}
