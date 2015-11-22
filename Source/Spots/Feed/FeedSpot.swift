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
  private var lastContentOffset = CGPoint()

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
    tableView.frame.size.width = UIScreen.mainScreen().bounds.width
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
  }

  public func setup() {
    if component.size == nil {
      var height = component.items.reduce(0, combine: { $0 + $1.size.height })

      if !component.title.isEmpty { height += headerHeight }

      tableView.frame.size.width = UIScreen.mainScreen().bounds.width
      tableView.frame.size.height = UIScreen.mainScreen().bounds.height - 64
      tableView.contentSize = CGSize(
        width: tableView.frame.width,
        height: height - tableView.contentInset.top - tableView.contentInset.bottom)
      tableView.addSubview(refreshControl)
    } else {
      tableView.scrollEnabled = false
    }

    FeedSpot.configure?(view: tableView)
  }
}

extension FeedSpot: UIScrollViewDelegate {

  public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    lastContentOffset = scrollView.contentOffset
  }

  public func scrollViewDidScroll(scrollView: UIScrollView) {
    let bounds = scrollView.bounds
    let inset = scrollView.contentInset
    let offset = scrollView.contentOffset
    let size = scrollView.contentSize
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

    let cell = tableView.dequeueReusableCellWithIdentifier(item(indexPath).kind, forIndexPath: indexPath)
    cell.optimize()

    (cell as? Itemble)?.configure(&component.items[indexPath.item])

    return cell
  }
}
