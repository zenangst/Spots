import UIKit

public protocol SpotsDelegate: class {

  func spotDidSelectItem(spot: Spotable, item: ListItem)
  func spotsDidReload(refreshControl: UIRefreshControl)
  func spotDidReachEnd(completion: (() -> Void)?)
}

extension SpotsDelegate {
  public func spotDidReachEnd(completion: (() -> Void)? = nil) {}
}
