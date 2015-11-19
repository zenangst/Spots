import UIKit
import Tailor
import Sugar

public class FeedSpot: NSObject, Spotable, Listable {

  public static var cells = [String : UIView.Type]()
  public static var headers = [String : UIView.Type]()
  public static var defaultCell: UIView.Type = FeedSpotCell.self
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
    prepareSpot(self)
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
