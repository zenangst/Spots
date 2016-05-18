import Cocoa
import Sugar
import Brick

public class GridSpot: NSObject, Gridable {

  public static var views = ViewRegistry()
  public static var grids = GridRegistry()
  public static var configure: ((view: NSCollectionView) -> Void)?
  public static var defaultView: RegularView.Type = NSView.self
  public static var defaultKind: StringConvertible = "grid"

  public weak var spotsDelegate: SpotsDelegate?

  public var cachedViews = [String : SpotConfigurable]()
  public var component: Component
  public var configure: (SpotConfigurable -> Void)?
  public var index = 0

  public private(set) var stateCache: SpotCache?
  
  public lazy var adapter: CollectionAdapter = CollectionAdapter(spot: self)
  @available(OSX 10.11, *)
  public lazy var layout = NSCollectionViewFlowLayout()

  public lazy var scrollView: ScrollView = ScrollView().then {
    $0.documentView = NSView()
    $0.autoresizingMask = [.ViewWidthSizable]
  }

  public lazy var collectionView: NSCollectionView = NSCollectionView().then {
    $0.autoresizingMask = [.ViewWidthSizable]
  }

  public required init(component: Component) {
    self.component = component
    super.init()
    
    setupCollectionView()
    scrollView.contentView.addSubview(collectionView)
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

  public func setupCollectionView() {
//    collectionView.maxNumberOfColumns = Int(component.span)
    if #available(OSX 10.11, *) {
      collectionView.delegate = adapter
      collectionView.dataSource = adapter
      collectionView.collectionViewLayout = layout
    } else {
      // Fallback on earlier versions
    }
  }

  public func render() -> RegularView {
    return scrollView
  }

  public func setup(size: CGSize) {
    component.items.enumerate().forEach {
      component.items[$0.index].size.width = size.width
    }
    scrollView.frame.size = size
    GridSpot.configure?(view: collectionView)
  }
  
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