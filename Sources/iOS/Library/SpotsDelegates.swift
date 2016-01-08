import UIKit

public protocol SpotsDelegate: class {

  func spotDidSelectItem(spot: Spotable, item: ListItem)
}

public protocol SpotsRefreshDelegate: class {

  func spotsDidReload(refreshControl: UIRefreshControl, completion: (() -> Void)?)
}

public protocol SpotsScrollDelegate: class {

  func spotDidReachEnd(completion: (() -> Void)?)
}

public protocol SpotsCarouselScrollDelegate: class {

  func spotDidEndScrolling(spot: Spotable, item: ListItem)
}
