import Spots
import Brick
import RxSwift
import RxCocoa

// MARK: - Delegate proxy

final class SpotDelegateProxy: DelegateProxy, DelegateProxyType, SpotsDelegate {

  private let spotDidSelectItem = PublishSubject<(Spotable, Item)>()
  private let spotDidChange = PublishSubject<[Spotable]>()
  private let spotWillDisplayView = PublishSubject<(Spotable, SpotView, Item)>()
  private let spotDidEndDisplayingView = PublishSubject<(Spotable, SpotView, Item)>()

  let didSelectItem: Observable<(Spotable, Item)>
  let didChange: Observable<[Spotable]>
  let willDisplayView: Observable<(Spotable, SpotView, Item)>
  let didEndDisplayingView: Observable<(Spotable, SpotView, Item)>

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

  required init(parentObject: AnyObject) {
    didSelectItem = spotDidSelectItem.observeOn(MainScheduler.instance)
    didChange = spotDidChange.observeOn(MainScheduler.instance)
    willDisplayView = spotWillDisplayView.observeOn(MainScheduler.instance)
    didEndDisplayingView = spotDidEndDisplayingView.observeOn(MainScheduler.instance)

    super.init(parentObject: parentObject)
  }

  func spotable(_ spot: Spotable, itemSelected item: Item) {
    spotDidSelectItem.onNext(spot, item)
  }

  func spotablesDidChange(_ spots: [Spotable]) {
    spotDidChange.onNext(spots)
  }

  func spotable(_ spot: Spotable, willDisplay view: SpotView, item: Item) {
    spotWillDisplayView.onNext(spot, view, item)
  }

  func spotable(_ spot: Spotable, didEndDisplaying view: SpotView, item: Item) {
    spotDidEndDisplayingView.onNext(spot, view, item)
  }
}
