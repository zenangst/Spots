// swiftlint:disable weak_delegate

import UIKit

/// A RowComponent, a collection view based Spotable object that lays out its items in a vertical order based of the item sizes
open class RowComponent: NSObject, Gridable {

  public static var layout: Layout = Layout(span: 1.0)

  /// A Registry object that holds identifiers and classes for cells used in the RowComponent
  open static var views: Registry = Registry()

  /// A configuration closure that is run in setup(_:)
  open static var configure: ((_ view: UICollectionView, _ layout: UICollectionViewFlowLayout) -> Void)?

  /// A Registry object that holds identifiers and classes for headers used in the RowComponent
  open static var headers = Registry()

  /// A SpotsFocusDelegate object
  weak public var focusDelegate: SpotsFocusDelegate?

  /// Child spots
  public var compositeComponents: [CompositeComponent] = []

  /// A component struct used as configuration and data source for the RowComponent
  open var model: ComponentModel

  /// A configuration closure
  open var configure: ((ItemConfigurable) -> Void)? {
    didSet {
      configureClosureDidChange()
    }
  }

  /// A SpotsDelegate that is used for the RowComponent
  open weak var delegate: SpotsDelegate?

  /// A custom UICollectionViewFlowLayout
  open lazy var layout: CollectionLayout = CollectionLayout()

  /// A StateCache for the RowComponent
  open fileprivate(set) var stateCache: StateCache?

  /// A UICollectionView, used as the main UI component for a RowComponent
  open lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
    collectionView.isScrollEnabled = false

    return collectionView
    }()

  public var userInterface: UserInterface?
  var spotDataSource: DataSource?
  var spotDelegate: Delegate?

  /// A required initializer to instantiate a RowComponent with a model.
  ///
  /// - parameter component: A model.
  ///
  /// - returns: An initialized row spot with model.
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
      self.model.kind = ComponentModel.Kind.row.string
    }

    registerDefault(view: RowSpotCell.self)
    registerComposite(view: GridComposite.self)
    prepareItems()
    configureCollectionView()

    if RowComponent.views.composite == nil {
      RowComponent.views.composite = Registry.Item.classType(GridComposite.self)
    }
  }

  /// Instantiate a RowComponent with a cache key.
  ///
  /// - parameter cacheKey: A unique cache key for the Spotable object
  ///
  /// - returns: An initialized row spot.
  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)

    self.init(model: ComponentModel(stateCache.load()))
    self.stateCache = stateCache
  }

  deinit {
    spotDataSource = nil
    spotDelegate = nil
    userInterface = nil
  }

  /// Configure collection view with data source, delegate and background view
  public func configureCollectionView() {
    register()
    collectionView.dataSource = spotDataSource
    collectionView.delegate = spotDelegate
  }
}
