import UIKit

extension Spot {

  func setupTableView(_ tableView: TableView, with size: CGSize) {
    tableView.dataSource = spotDataSource
    tableView.delegate = spotDelegate
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.frame.size = size
    tableView.frame.size.width = round(size.width - (tableView.contentInset.left))
    tableView.frame.origin.x = round(size.width / 2 - tableView.frame.width / 2)

    prepareItems()

    var height: CGFloat = 0.0
    for item in component.items {
      height += item.size.height
    }

    tableView.contentSize = CGSize(
      width: tableView.frame.size.width,
      height: height - tableView.contentInset.top - tableView.contentInset.bottom)

    /// On iOS 8 and prior, the second cell always receives the same height as the first cell. Setting estimatedRowHeight magically fixes this issue. The value being set is not relevant.
    if #available(iOS 9, *) {
      return
    } else {
      tableView.estimatedRowHeight = 10
    }
  }

  func layoutTableView(_ tableView: TableView, with size: CGSize) {
    tableView.frame.size.width = round(size.width - (tableView.contentInset.left))
    tableView.frame.origin.x = round(size.width / 2 - tableView.frame.width / 2)
  }
}
