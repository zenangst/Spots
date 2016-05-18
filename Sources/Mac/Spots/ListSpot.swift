import Cocoa
import Sugar
import Brick

public class ListSpot: NSObject, Spotable {

  public static var views = ViewRegistry()
  public static var configure: ((view: NSTableView) -> Void)?
  public static var defaultView: RegularView.Type = ListSpotItem.self
  public static var defaultKind: StringConvertible = "list"

  public weak var spotsDelegate: SpotsDelegate?

  public var cachedViews = [String : SpotConfigurable]()
  public var component: Component
  public var configure: (SpotConfigurable -> Void)?
  public var index = 0

  public private(set) var stateCache: SpotCache?

  public lazy var adapter: ListAdapter = ListAdapter(spot: self)
  
  public lazy var scrollView: ScrollView = ScrollView().then {
    $0.documentView = NSView()
    $0.autoresizingMask = .ViewWidthSizable
  }

  public lazy var tableView: NSTableView = NSTableView(frame: CGRectZero).then {
    $0.allowsColumnReordering = false
    $0.allowsColumnResizing = false
    $0.allowsColumnSelection = false
    $0.allowsEmptySelection = true
    $0.allowsMultipleSelection = false
    $0.headerView = nil
    $0.selectionHighlightStyle = .None
  }

  public required init(component: Component) {
    self.component = component
    super.init()

    setupTableView()
    scrollView.contentView.addSubview(tableView)
  }

  public convenience init(title: String = "", kind: String? = nil) {
    self.init(component: Component(title: title, kind: kind ?? GridSpot.defaultKind.string))
  }

  public convenience init(cacheKey: String) {
    let stateCache = SpotCache(key: cacheKey)

    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache

    //prepare()
  }

  public func setupTableView() {
    tableView.setDelegate(adapter)
    tableView.setDataSource(adapter)
    tableView.target = self
    tableView.doubleAction = #selector(self.doubleAction(_:))
  }

  public func doubleAction(sender: AnyObject?) {
    let viewModel = item(tableView.selectedRow)
    spotsDelegate?.spotDidSelectItem(self, item: viewModel)
  }

  public func render() -> RegularView {
    return scrollView
  }

  public func setup(size: CGSize) {
    component.items.enumerate().forEach {
      component.items[$0.index].size.width = size.width
    }
    scrollView.frame.size = size
    ListSpot.configure?(view: tableView)
  }

  private func refreshHeight(completion: (() -> Void)? = nil) {
    delay(0.2) { [weak self] in
      guard let weakSelf = self, tableView = self?.tableView else { return; completion?() }
      weakSelf.setup(CGSize(width: tableView.frame.width, height: weakSelf.spotHeight() ?? 0))
      completion?()
    }
  }

  public func append(item: ViewModel, withAnimation animation: SpotsAnimation, completion: Completion) {
    let count = component.items.count
    component.items.append(item)

    dispatch { [weak self] in
      guard let tableView = self?.tableView else { completion?(); return }
      tableView.insert([count], animation: animation.tableViewAnimation) {
        self?.setup(tableView.frame.size)
        completion?()
      }
    }
  }
  public func append(items: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion) {
    var indexes = [Int]()
    let count = component.items.count

    component.items.appendContentsOf(items)

    items.enumerate().forEach {
      indexes.append(count + $0.index)
    }

    dispatch { [weak self] in
      guard let tableView = self?.tableView else { completion?(); return }
      tableView.insert(indexes, animation: animation.tableViewAnimation) {
        self?.setup(tableView.frame.size)
        completion?()
      }
    }
  }

  public func prepend(items: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion) {
    var indexes = [Int]()

    component.items.insertContentsOf(items, at: 0)

    items.enumerate().forEach {
      indexes.append(items.count - 1 - $0.index)
    }

    dispatch { [weak self] in
      guard let tableView = self?.tableView else { completion?(); return }
      tableView.insert(indexes, animation: animation.tableViewAnimation) {
        self?.refreshHeight()
      }
    }
  }
  
  public func insert(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {
    component.items.insert(item, atIndex: index)

    dispatch { [weak self] in
      guard let tableView = self?.tableView else { completion?(); return }
      tableView.insert([index], animation: animation.tableViewAnimation) {
        self?.refreshHeight(completion)
      }
    }
  }
  
  public func update(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {
    items[index] = item

    dispatch { [weak self] in
      guard let tableView = self?.tableView else { completion?(); return }
      tableView.reload([index], section: 0, animation: animation.tableViewAnimation) {
        self?.refreshHeight(completion)
      }
    }
  }
  
  public func delete(item: ViewModel, withAnimation animation: SpotsAnimation, completion: Completion) {
    guard let index = component.items.indexOf({ $0 == item })
      else { completion?(); return }

    component.items.removeAtIndex(index)

    dispatch { [weak self] in
      guard let tableView = self?.tableView else { completion?(); return }
      tableView.delete([index], animation: animation.tableViewAnimation) {
        self?.refreshHeight(completion)
      }
    }
  }

  public func delete(item: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion) {
    var indexPaths = [Int]()
    let count = component.items.count

    for (index, item) in items.enumerate() {
      indexPaths.append(count + index)
      component.items.append(item)
    }

    dispatch { [weak self] in
      guard let tableView = self?.tableView else { completion?(); return }
      tableView.delete(indexPaths, animation: animation.tableViewAnimation) {
        self?.refreshHeight(completion)
      }
    }
  }
  
  public func delete(index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {
    dispatch { [weak self] in
      guard let tableView = self?.tableView else { completion?(); return }
      self?.component.items.removeAtIndex(index)
      tableView.delete([index], animation: animation.tableViewAnimation) {
        self?.refreshHeight(completion)
      }
    }
  }
  
  public func delete(indexes: [Int], withAnimation animation: SpotsAnimation, completion: Completion) {
    dispatch { [weak self] in
      indexes.forEach { self?.component.items.removeAtIndex($0) }
      guard let tableView = self?.tableView else { completion?(); return }
      tableView.delete(indexes, animation: animation.tableViewAnimation) {
        self?.refreshHeight(completion)
      }
    }
  }
  
  public func reload(indexes: [Int]?, withAnimation animation: SpotsAnimation, completion: Completion) {
    dispatch { [weak self] in
      guard let tableView = self?.tableView else { completion?(); return }
      if let indexes = indexes where animation != .None {
        tableView.reload(indexes, animation: animation.tableViewAnimation) {
          self?.refreshHeight(completion)
        }
      } else {
        tableView.reloadData()
        self?.setup(tableView.frame.size)
        completion?()
      }
    }
  }
}