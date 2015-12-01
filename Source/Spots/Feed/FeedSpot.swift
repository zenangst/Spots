import UIKit
import Tailor
import Sugar

public class FeedSpot: NSObject, Spotable, Listable {

  public static var cells = [String : UIView.Type]()
  public static var configure: ((view: UITableView) -> Void)?
  public static var defaultCell: UIView.Type = FeedSpotCell.self
  public static var headers = [String : UIView.Type]()

  public var cachedHeaders = [String : Componentable]()
  public var cachedCells = [String : Itemble]()
  public var headerHeight: CGFloat = 44

  public let itemHeight: CGFloat = 44

  public var component: Component
  public var index = 0

  public weak var sizeDelegate: SpotSizeDelegate?
  public weak var spotDelegate: SpotsDelegate?

  private var fetching = false

  public lazy var tableView: UITableView = { [unowned self] in
    let tableView = UITableView()
    tableView.autoresizesSubviews = true
    tableView.autoresizingMask = [
      .FlexibleWidth,
      .FlexibleRightMargin,
      .FlexibleLeftMargin
    ]
    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = UITableViewAutomaticDimension

    return tableView
    }()

  public lazy var refreshControl: UIRefreshControl = { [unowned self] in
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: "refreshSpot:", forControlEvents: .ValueChanged)

    return refreshControl
    }()

  public required init(component: Component) {
    self.component = component
    super.init()
    prepareSpot(self)
    tableView.addSubview(refreshControl)

    let reuseIdentifer = component.kind.isEmpty ? "feed" : component.kind
    if let headerType = ListSpot.headers[reuseIdentifer] {
      let header = headerType.init(frame: CGRect(x: 0, y: 0,
        width: UIScreen.mainScreen().bounds.width, height: headerHeight))

      if let configurable = header as? Componentable {
        configurable.configure(component)
        cachedHeaders[reuseIdentifer] = configurable
        headerHeight = configurable.height
      }
    }
  }

  public func setup(size: CGSize) {
    if component.size == nil {
      var height = component.items.reduce(0, combine: { $0 + $1.size.height })

      if !component.title.isEmpty { height += headerHeight }

      tableView.frame.size = size
      tableView.frame.size.height = size.height - 64
      tableView.contentSize = CGSize(
        width: tableView.frame.width,
        height: height - tableView.contentInset.top - tableView.contentInset.bottom)
    } else {
      tableView.scrollEnabled = false
    }

    FeedSpot.configure?(view: tableView)
  }
}

extension FeedSpot: UIScrollViewDelegate {

  public func scrollViewDidScroll(scrollView: UIScrollView) {
    let bounds = scrollView.bounds
    let inset = scrollView.contentInset
    let offset = scrollView.contentOffset
    let size = scrollView.contentSize
    let shouldFetch = offset.y + bounds.size.height - inset.bottom > size.height - headerHeight - itemHeight
      && size.height > bounds.size.height
      && !fetching

    if shouldFetch && !fetching {
      fetching = true
      spotDelegate?.spotDidReachEnd {
        self.fetching = false
      }
    }
  }
}

// MARK: - Refresh

extension FeedSpot {

  public func refreshSpot(refreshControl: UIRefreshControl) {
    dispatch { [weak self] in
      if let weakSelf = self, spotDelegate = weakSelf.spotDelegate {
        spotDelegate.spotsDidReload(refreshControl)
      } else {
        delay(0.5) { [weak self] in
          self?.refreshControl.endRefreshing()
        }
      }
    }
  }
}

extension FeedSpot: UITableViewDelegate {

  public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return !component.title.isEmpty ? headerHeight : 0
  }

  public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return component.title
  }

  public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    spotDelegate?.spotDidSelectItem(self, item: item(indexPath))
  }

  public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let reuseIdentifer = component.kind.isEmpty ? "feed" : component.kind
    if let cachedHeader = cachedHeaders[reuseIdentifer] {
      cachedHeader.configure(component)
      return cachedHeader as? UIView
    } else if let header = ListSpot.headers[reuseIdentifer] {
      let header = header.init(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerHeight))
      return header
    }

    return nil
  }

  public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if let spotsController = sizeDelegate as? SpotsController {
      tableView.contentInset.top = spotsController.layout.sectionInset.top
      tableView.contentInset.bottom = spotsController.layout.sectionInset.bottom
    }

    component.size = CGSize(
      width: tableView.frame.width,
      height: tableView.frame.height)
    sizeDelegate?.sizeDidUpdate()

    return item(indexPath).size.height
  }
}

extension FeedSpot: UITableViewDataSource {

  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return component.items.count
  }

  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    component.items[indexPath.item].index = indexPath.row

    let reuseIdentifier = !item(indexPath).kind.isEmpty ? item(indexPath).kind : component.kind
    let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
    cell.optimize()

    (cell as? Itemble)?.configure(&component.items[indexPath.item])

    return cell
  }
}
