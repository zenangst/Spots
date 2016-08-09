import UIKit
import Sugar
import Brick

public extension Spotable where Self : Listable {

  /**
   Called when the Listable object is being prepared, it is required by Spotable
   */
  public func prepare() {

  }

  /**
   - Returns: UIScrollView: Returns a UITableView as a UIScrollView
   */
  public func render() -> UIScrollView {
    return tableView
  }

  /**
   - Parameter size: A CGSize to set the width of the table view
   */
  public func layout(size: CGSize) {
    tableView.width = size.width
    tableView.layoutIfNeeded()
  }

  /**
   - Parameter includeElement: A filter predicate to find a view model
   - Returns: A calculate CGFloat based on what the includeElement matches
   */
  public func scrollTo(@noescape includeElement: (ViewModel) -> Bool) -> CGFloat {
    guard let item = items.filter(includeElement).first else { return 0.0 }

    return component.items[0...item.index]
      .reduce(0, combine: { $0 + $1.size.height })
  }
}
