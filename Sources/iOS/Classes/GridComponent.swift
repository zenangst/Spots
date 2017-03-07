// swiftlint:disable weak_delegate

import UIKit

/// A GridComponent, a collection view based CoreComponent object that lays out its items in a vertical order based of the item sizes
open class GridComponent: NSObject, Gridable {

  public static var layout = Layout(span: 0.0)

  /// A Registry object that holds identifiers and classes for cells used in the GridComponent
  open static var views: Registry = Registry()

  /// A configuration closure that is run in setup(_:)
  open static var configure: ((_ view: UICollectionView, _ layout: UICollectionViewFlowLayout) -> Void)?

  /// A Registry object that holds identifiers and classes for headers used in the GridComponent
  open static var headers = Registry()

  /// A SpotsFocusDelegate object
  weak public var focusDelegate: ComponentFocusDelegate?

  /// Child spots
  public var compositeComponents: [CompositeComponent] = []

  /// A component struct used as configuration and data source for the GridComponent
  open var model: ComponentModel

  /// A configuration closure
  open var configure: ((ItemConfigurable) -> Void)? {
    didSet {
      configureClosureDidChange()
    }
  }

  /// A ComponentDelegate that is used for the GridComponent
  open weak var delegate: ComponentDelegate?

  /// A custom UICollectionViewFlowLayout
  open lazy var layout: CollectionLayout = CollectionLayout()

  /// A StateCache for the GridComponent
  open fileprivate(set) var stateCache: StateCache?

  /// A UICollectionView, used as the main UI component for a GridComponent
  open lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
    collectionView.isScrollEnabled = false
    collectionView.clipsToBounds = false

    return collectionView
    }()

  public var userInterface: UserInterface?
  var spotDataSource: DataSource?
  var spotDelegate: Delegate?

  /// A required initializer to instantiate a GridComponent with a model.
  ///
  /// - parameter component: A model.
  ///
  /// - returns: An initialized grid spot with model.
  public required init(model: ComponentModel) {
    self.model = model

    if self.model.layout == nil {
      self.model.layout = type(of: self).layout
    }

    super.init()
    self.userInterface = collectionView
    self.model.layout?.configure(spot: self)
    self.spotDataSource = DataSource(spot: self)
    self.spotDelegate = Delegate(spot: self)

    if model.kind.isEmpty {
      self.model.kind = ComponentModel.Kind.grid.string
    }

    registerDefault(view: GridComponentCell.self)
    registerComposite(view: GridComposite.self)
    registerAndPrepare()
    configureCollectionView()

    if GridComponent.views.composite == nil {
      GridComponent.views.composite =  Registry.Item.classType(GridComposite.self)
    }
  }

  /// A convenience init for initializing a Gridspot with a title and a kind.
  ///
  ///  - parameter title: A string that is used as a title for the GridComponent.
  ///  - parameter kind:  An identifier to determine which kind should be set on the ComponentModel.
  ///
  /// - returns: An initialized grid spot with computed component using title and kind.
  public convenience init(title: String = "", kind: String? = nil) {
    self.init(model: ComponentModel(title: title, kind: kind ?? "", span: 0.0))
  }

  /// Instantiate a GridComponent with a cache key.
  ///
  /// - parameter cacheKey: A unique cache key for the CoreComponent object
  ///
  /// - returns: An initialized grid spot.
  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)

    self.init(model: ComponentModel(stateCache.load()))
    self.stateCache = stateCache
  }

  /// Configure collection view with data source, delegate and background view
  public func configureCollectionView() {
    register()
    collectionView.dataSource = spotDataSource
    collectionView.delegate = spotDelegate
  }

  deinit {
    spotDataSource = nil
    spotDelegate = nil
    userInterface = nil
  }
}
