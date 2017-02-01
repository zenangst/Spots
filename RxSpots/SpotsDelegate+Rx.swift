import Spots
import Brick
import RxSwift
import RxCocoa

// MARK: - Delegate proxy

final class SpotDelegateProxy: DelegateProxy, DelegateProxyType, SpotsDelegate {

  class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
    return (object as? Spotable)?.delegate ?? (object as? Controller)?.delegate
  }

  class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
    if let spot = object as? Spotable {
      spot.delegate = delegate as? SpotsDelegate
    } else if let controller = object as? Controller {
      controller.delegate = delegate as? SpotsDelegate
    }
  }
}
