#if !COCOAPODS
import Spots
#endif
import RxSwift
import RxCocoa

// MARK: - Delegate proxy

/**
 Delegate proxy for ComponentDelegate
 */
public final class RxComponentDelegate: DelegateProxy, DelegateProxyType, ComponentDelegate {

  // Delegate methods subjects
  private let componentDidSelectItem = PublishSubject<(CoreComponent, Item)>()
  private let componentsDidChange = PublishSubject<[CoreComponent]>()
  private let componentWillDisplayView = PublishSubject<(CoreComponent, ComponentView, Item)>()
  private let componentDidEndDisplayingView = PublishSubject<(CoreComponent, ComponentView, Item)>()

  // Delegate method observables
  public let didSelectItem: Observable<(CoreComponent, Item)>
  public let didChange: Observable<[CoreComponent]>
  public let willDisplayView: Observable<(CoreComponent, ComponentView, Item)>
  public let didEndDisplayingView: Observable<(CoreComponent, ComponentView, Item)>

  public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
    return (object as? CoreComponent)?.delegate ?? (object as? Controller)?.delegate
  }

  public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
    if let spot = object as? CoreComponent {
      spot.delegate = delegate as? ComponentDelegate
    } else if let controller = object as? Controller {
      controller.delegate = delegate as? ComponentDelegate
    }
  }

  public required init(parentObject: AnyObject) {
    didSelectItem = componentDidSelectItem.observeOn(MainScheduler.instance)
    didChange = componentsDidChange.observeOn(MainScheduler.instance)
    willDisplayView = componentWillDisplayView.observeOn(MainScheduler.instance)
    didEndDisplayingView = componentDidEndDisplayingView.observeOn(MainScheduler.instance)

    super.init(parentObject: parentObject)
  }

  public func component(_ component: CoreComponent, itemSelected item: Item) {
    componentDidSelectItem.onNext(component, item)
  }

  public func componentsDidChange(_ components: [CoreComponent]) {
    componentsDidChange.onNext(components)
  }

  public func component(_ component: CoreComponent, willDisplay view: ComponentView, item: Item) {
    componentWillDisplayView.onNext(component, view, item)
  }

  public func component(_ component: CoreComponent, didEndDisplaying view: ComponentView, item: Item) {
    componentDidEndDisplayingView.onNext(component, view, item)
  }
}

// MARK: - Reactive extensions

extension Reactive where Base: CoreComponent {

  public var delegate: RxComponentDelegate {
    return RxComponentDelegate.proxyForObject(base)
  }
}

extension Reactive where Base: SpotsProtocol {

  public var delegate: RxComponentDelegate {
    return RxComponentDelegate.proxyForObject(base)
  }
}
