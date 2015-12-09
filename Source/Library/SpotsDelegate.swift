import UIKit

public protocol SpotsDelegate: class {

  func spotDidSelectItem(spot: Spotable, item: ListItem)
}

public protocol SpotsScrollDelegate: class {

  func spotsDidReload(refreshControl: UIRefreshControl, completion: (() -> Void)?)
  func spotDidReachEnd(completion: (() -> Void)?)
}

extension SpotsDelegate {

  public func spotDidReachEnd(completion: (() -> Void)? = nil) {}
}
