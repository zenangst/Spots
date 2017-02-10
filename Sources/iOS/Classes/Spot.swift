// swiftlint:disable weak_delegate

import UIKit
import Tailor

public class Spot: NSObject, Spotable {

  public static var layout: Layout = Layout(span: 1.0)
  public static var headers: Registry = Registry()
  public static var views: Registry = Registry()
  public static var defaultKind: String = Component.Kind.list.string

  open static var configure: ((_ view: View) -> Void)?

  weak public var focusDelegate: SpotsFocusDelegate?
  weak public var delegate: SpotsDelegate?

  public var component: Component
  public var componentKind: Component.Kind = .list
  public var compositeSpots: [CompositeSpot] = []

  public var configure: ((SpotConfigurable) -> Void)? {
    didSet {
      configureClosureDidChange()
    }
  }

  public var spotDelegate: Delegate?
  public var spotDataSource: DataSource?
  public var stateCache: StateCache?

  public var userInterface: UserInterface? {
    return self.view as? UserInterface
  }

  open lazy var pageControl = UIPageControl()
  open lazy var backgroundView = UIView()

  var collectionViewLayout: CollectionLayout?

  public var view: ScrollView

  public var tableView: TableView? {
    return userInterface as? TableView
  }

  public var collectionView: CollectionView? {
    return userInterface as? CollectionView
  }

  public required init(component: Component) {
    var component = component
    if component.kind.isEmpty {
      component.kind = Spot.defaultKind
    }

    self.component = component

    if let componentKind = Component.Kind(rawValue: component.kind) {
      self.componentKind = componentKind
    }

    self.component.layout = ListSpot.layout
    self.view = TableView()

    super.init()

    if component.layout == nil {
      switch componentKind {
      case .carousel:
        self.component.layout = CarouselSpot.layout
      case .grid:
        self.component.layout = GridSpot.layout
      case .list:
        self.component.layout = ListSpot.layout
      case .row:
        self.component.layout = RowSpot.layout
      default:
        break
      }
    }

    self.spotDataSource = DataSource(spot: self)
    self.spotDelegate = Delegate(spot: self)
    ¸
    prepareItems()
  }

  deinit {
    spotDataSource = nil
    spotDelegate = nil
  }

  public func configure(with layout: Layout) {

  }

  public func setup(_ size: CGSize) {
    type(of: self).configure?(view)

    if let tableView = self.tableView {
      setupTableView(tableView, with: size)
    } else if let collectionView = self.collectionView {
      setupCollectionView(collectionView, with: size)
    }

    layout(size)
  }

  public func layout(_ size: CGSize) {
    if let tableView = self.tableView {
      layoutTableView(tableView, with: size)
    } else if let collectionView = self.collectionView {
      layoutCollectionView(collectionView, with: size)
    }
  }

  fileprivate func setupTableView(_ tableView: TableView, with size: CGSize) {
    var height: CGFloat = 0.0
    for item in component.items {
      height += item.size.height
    }

    tableView.dataSource = spotDataSource
    tableView.delegate = spotDelegate
    tableView.frame.size = size
    tableView.frame.size.width = round(size.width - (tableView.contentInset.left))
    tableView.frame.origin.x = round(size.width / 2 - tableView.frame.width / 2)
    tableView.contentSize = CGSize(
      width: tableView.frame.size.width,
      height: height - tableView.contentInset.top - tableView.contentInset.bottom)
  }

  fileprivate func setupCollectionView(_ collectionView: CollectionView, with size: CGSize) {
    collectionView.dataSource = spotDataSource
    collectionView.delegate = spotDelegate
  }

  fileprivate func setupHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize) {

  }

  fileprivate func setupVerticalCollectionView(_ collectionView: CollectionView, with size: CGSize) {
  }

  fileprivate func layoutCollectionView(_ collectionView: CollectionView, with size: CGSize) {

  }

  fileprivate func layoutTableView(_ tableView: TableView, with size: CGSize) {
    tableView.frame.size.width = round(size.width - (tableView.contentInset.left))
    tableView.frame.origin.x = round(size.width / 2 - tableView.frame.width / 2)
  }

  fileprivate func layoutHorizontalCollectionView(_ collectionView: CollectionView, with size: CGSize) {

  }

  fileprivate func layoutVerticalCollectionView(_ collectionView: CollectionView, with size: CGSize) {

  }

  func registerDefaultIfNeeded(view: View.Type) {
    if Configuration.views.storage[Configuration.views.defaultIdentifier] == nil {
      Configuration.views.defaultItem = Registry.Item.classType(view)
    }
  }

  public func register() {

  }
}
