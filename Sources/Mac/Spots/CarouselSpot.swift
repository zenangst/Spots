import Cocoa
import Sugar
import Brick

public class CarouselSpot: NSObject, Spotable {

  public static var views = ViewRegistry()
  public static var defaultView: RegularView.Type = GridSpotCell.self
  public static var defaultKind: StringConvertible = "carousel"

  public weak var spotsDelegate: SpotsDelegate?

  public var cachedViews = [String : SpotConfigurable]()
  public var component: Component
  public var configure: (SpotConfigurable -> Void)?
  public var index = 0

  public private(set) var stateCache: SpotCache?

  public lazy var collectionView: NSCollectionView = NSCollectionView(frame: CGRectZero).then {_ in
    //    $0.backgroundColor = UIColor.whiteColor()
    //    $0.dataSource = self.adapter
    //    $0.delegate = self.adapter
    //    $0.scrollEnabled = false
  }

  public required init(component: Component) {
    self.component = component
    super.init()
  }

  public convenience init(title: String = "", kind: String? = nil) {
    self.init(component: Component(title: title, kind: kind ?? GridSpot.defaultKind.string))
  }

  public convenience init(cacheKey: String) {
    let stateCache = SpotCache(key: cacheKey)

    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache

    //prepare()
  }

  public func render() -> RegularView {
    return collectionView
  }

  public func setup(size: CGSize) {}
  public func append(item: ViewModel, withAnimation animation: SpotsAnimation, completion: Completion) {}
  public func append(items: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion) {}
  public func prepend(items: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion) {}
  public func insert(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {}
  public func update(item: ViewModel, index: Int, withAnimation animation: SpotsAnimation, completion: Completion){}
  public func delete(item: ViewModel, withAnimation animation: SpotsAnimation, completion: Completion) {}
  public func delete(item: [ViewModel], withAnimation animation: SpotsAnimation, completion: Completion) {}
  public func delete(index: Int, withAnimation animation: SpotsAnimation, completion: Completion) {}
  public func delete(indexes: [Int], withAnimation animation: SpotsAnimation, completion: Completion) {}
  public func reload(indexes: [Int]?, withAnimation animation: SpotsAnimation, completion: Completion) {}
}