import Spots
import Brick
import RxSwift
import RxCocoa

// MARK: - Delegate proxy

/**
 Delegate proxy for SpotsDelegate
 */
public final class RxSpotsDelegate: DelegateProxy, DelegateProxyType, SpotsDelegate {

  // Delegate methods subjects
  private let spotDidSelectItem = PublishSubject<(Spotable, Item)>()
  private let spotDidChange = PublishSubject<[Spotable]>()
  private let spotWillDisplayView = PublishSubject<(Spotable, SpotView, Item)>()
  private let spotDidEndDisplayingView = PublishSubject<(Spotable, SpotView, Item)>()

  // Delegate method observables
  public let didSelectItem: Observable<(Spotable, Item)>
  public let didChange: Observable<[Spotable]>
  public let willDisplayView: Observable<(Spotable, SpotView, Item)>
  public let didEndDisplayingView: Observable<(Spotable, SpotView, Item)>

  public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
    return (object as? Spotable)?.delegate ?? (object as? Controller)?.delegate
  }

  public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
    if let spot = object as? Spotable {
      spot.delegate = delegate as? SpotsDelegate
    } else if let controller = object as? Controller {
      controller.delegate = delegate as? SpotsDelegate
    }
  }

  public required init(parentObject: AnyObject) {
    didSelectItem = spotDidSelectItem.observeOn(MainScheduler.instance)
    didChange = spotDidChange.observeOn(MainScheduler.instance)
    willDisplayView = spotWillDisplayView.observeOn(MainScheduler.instance)
    didEndDisplayingView = spotDidEndDisplayingView.observeOn(MainScheduler.instance)

    super.init(parentObject: parentObject)
  }

  public func spotable(_ spot: Spotable, itemSelected item: Item) {
    spotDidSelectItem.onNext(spot, item)
  }

  public func spotablesDidChange(_ spots: [Spotable]) {
    spotDidChange.onNext(spots)
  }

  public func spotable(_ spot: Spotable, willDisplay view: SpotView, item: Item) {
    spotWillDisplayView.onNext(spot, view, item)
  }

  public func spotable(_ spot: Spotable, didEndDisplaying view: SpotView, item: Item) {
    spotDidEndDisplayingView.onNext(spot, view, item)
  }
}

// MARK: - Reactive extensions

extension Reactive where Base: Spotable {

  public var delegate: RxSpotsDelegate {
    return RxSpotsDelegate.proxyForObject(base)
  }
}

extension Reactive where Base: SpotsProtocol {

  public var delegate: RxSpotsDelegate {
    return RxSpotsDelegate.proxyForObject(base)
  }
}
