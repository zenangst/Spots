import UIKit

public protocol SpotsDelegate: class {

  func spotDidSelectItem(spot: Spotable, item: ListItem)
  func spotsDidReload(refreshControl: UIRefreshControl)
}
