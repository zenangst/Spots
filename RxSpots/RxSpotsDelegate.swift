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
  private let componentDidSelectItem = PublishSubject<(Component, Item)>()
  private let componentsDidChange = PublishSubject<[Component]>()
  private let componentWillDisplayView = PublishSubject<(Component, ComponentView, Item)>()
  private let componentDidEndDisplayingView = PublishSubject<(Component, ComponentView, Item)>()

  // Delegate method observables
  public let didSelectItem: Observable<(Component, Item)>
  public let didChange: Observable<[Component]>
  public let willDisplayView: Observable<(Component, ComponentView, Item)>
  public let didEndDisplayingView: Observable<(Component, ComponentView, Item)>

  public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
    return (object as? Component)?.delegate ?? (object as? SpotsController)?.delegate
  }

  public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
    if let component = object as? Component {
      component.delegate = delegate as? ComponentDelegate
    } else if let controller = object as? SpotsController {
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

  public func component(_ component: Component, itemSelected item: Item) {
    componentDidSelectItem.onNext(component, item)
  }

  public func componentsDidChange(_ components: [Component]) {
    componentsDidChange.onNext(components)
  }

  public func component(_ component: Component, willDisplay view: ComponentView, item: Item) {
    componentWillDisplayView.onNext(component, view, item)
  }

  public func component(_ component: Component, didEndDisplaying view: ComponentView, item: Item) {
    componentDidEndDisplayingView.onNext(component, view, item)
  }
}

// MARK: - Reactive extensions

extension Reactive where Base: Component {

  public var delegate: RxComponentDelegate {
    return RxComponentDelegate.proxyForObject(base)
  }
}

extension Reactive where Base: SpotsProtocol {

  public var delegate: RxComponentDelegate {
    return RxComponentDelegate.proxyForObject(base)
  }
}
