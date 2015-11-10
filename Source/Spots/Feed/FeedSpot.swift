import UIKit
import Tailor
import Sugar
import GoldenRetriever

public class FeedSpot: NSObject, Spotable {

  private var cachedCells = [String : Itemble]()
  private var lastContentOffset = CGPoint()

  public static var cells = [String : UITableViewCell.Type]()
  public static var headers = [String : UIView.Type]()
  
  public let itemHeight: CGFloat = 44
  public let headerHeight: CGFloat = 44

  public var component: Component
  public weak var sizeDelegate: SpotSizeDelegate?
  public weak var spotDelegate: SpotsDelegate?

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
      let componentCellClass = FeedSpot.cells[item.kind] ?? FeedSpotCell.self
      if let cachedCell = cachedCells[item.kind] {
        cachedCell.configure(&self.component.items[index])
      } else if let listCell = componentCellClass.init() as? Itemble {
        self.tableView.registerClass(componentCellClass,
          forCellReuseIdentifier: "FeedCell\(item.kind)")
        listCell.configure(&self.component.items[index])
        cachedCells[item.kind] = listCell
      }
    }

    cachedCells.removeAll()
  }

  public func render() -> UIView {
    if component.size == nil {
      var newHeight = component.items.reduce(0, combine: { $0 + $1.size.height })
      if !component.title.isEmpty { newHeight += headerHeight }
      tableView.frame.size.width = UIScreen.mainScreen().bounds.width
      tableView.frame.size.height = UIScreen.mainScreen().bounds.height - 64
      tableView.contentSize = CGSize(width: tableView.frame.width, height: newHeight - tableView.contentInset.top - tableView.contentInset.bottom)
    } else {
      tableView.scrollEnabled = false
    }
    
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
    if scrollView.contentOffset.y < 0.0 {
      tableView.scrollEnabled = false
      sizeDelegate?.scrollToPreviousCell(component)
    } else if scrollView.contentOffset.y == 0.0 {
      tableView.scrollEnabled = true
    } else if scrollView.contentOffset.y >= tableView.contentSize.height + tableView.contentInset.bottom - tableView.bounds.height {
      sizeDelegate?.scrollToNextCell(component)
    } else if lastContentOffset.y > scrollView.contentOffset.y {
      sizeDelegate?.scrollToPreviousCell(component)
      lastContentOffset = CGPoint(x: 0, y: 0)
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
    component.size = ComponentSize(width: tableView.frame.width, height: tableView.frame.height)
    sizeDelegate?.sizeDidUpdate()

    return component.items[indexPath.item].size.height
  }
}

extension FeedSpot: UITableViewDataSource {

  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return component.items.count
  }

  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell: UITableViewCell

    cell = tableView.dequeueReusableCellWithIdentifier("FeedCell\(self.component.items[indexPath.item].kind)", forIndexPath: indexPath)
    cell.optimize()

    guard let itemable = cell as? Itemble else { return cell }
    
    itemable.configure(&self.component.items[indexPath.item])

    return cell
  }
}
