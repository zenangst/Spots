import UIKit
import Tailor
import Sugar

public class FeedSpot: NSObject, Spotable, Listable {

  public static var cells = [String : UIView.Type]()
  public static var configure: ((view: UITableView) -> Void)?
  public static var defaultCell: UIView.Type = FeedSpotCell.self
  public static var headers = [String : UIView.Type]()

  public var cachedCells = [String : Itemble]()
  public let itemHeight: CGFloat = 44
  public let headerHeight: CGFloat = 44

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

  public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    spotDelegate?.spotDidSelectItem(self, item: item(indexPath))
  }

  public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    var height = component.items.reduce(0, combine: { $0 + $1.size.height })

    if !component.title.isEmpty { height += headerHeight }

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
