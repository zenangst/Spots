import UIKit
import Brick

public protocol SpotsDelegate: class {

  func spotDidSelectItem(spot: Spotable, item: ViewModel)
}

public protocol SpotsRefreshDelegate: class {

  func spotsDidReload(refreshControl: UIRefreshControl, completion: (() -> Void)?)
}

public protocol SpotsScrollDelegate: class {

  func spotDidReachBeginning(completion: (() -> Void)?)
  func spotDidReachEnd(completion: (() -> Void)?)
}

public extension SpotsScrollDelegate {

  func spotDidReachBeginning(completion: (() -> Void)?) {
    completion?()
  }
}

public protocol SpotsCarouselScrollDelegate: class {

  func spotDidEndScrolling(spot: Spotable, item: ViewModel)
}
