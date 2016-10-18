import UIKit
import Brick

/// A GridSpot, a collection view based Spotable object that lays out its items in a vertical order based of the item sizes
open class GridSpot: NSObject, Gridable {

  /**
   *  Keys for meta data lookup
   */
  public struct Key {
    /// The key for minimum interitem spacing
    public static let minimumInteritemSpacing = "item-spacing"
    /// The key for minimum line spacing
    public static let minimumLineSpacing = "line-spacing"
  }

  /**
   *  Default configuration values for GridSpot
   */
  public struct Default {
    /// Default top section inset
    public static var sectionInsetTop: CGFloat = 0.0
    /// Default left section inset
    public static var sectionInsetLeft: CGFloat = 0.0
    /// Default right section inset
    public static var sectionInsetRight: CGFloat = 0.0
    /// Default bottom section inset
    public static var sectionInsetBottom: CGFloat = 0.0
    /// Default minimum interitem spacing
    public static var minimumInteritemSpacing: CGFloat = 0.0
    /// Default minimum line spacing
    public static var minimumLineSpacing: CGFloat = 0.0
    /// Default left section inset
    public static var contentInsetLeft: CGFloat = 0.0
    /// Default right section inset
    public static var contentInsetRight: CGFloat = 0.0
  }

  /// A Registry object that holds identifiers and classes for cells used in the GridSpot
  open static var views: Registry = Registry()

  /// A configuration closure that is run in setup(_:)
  open static var configure: ((_ view: UICollectionView, _ layout: UICollectionViewFlowLayout) -> Void)?

  /// A Registry object that holds identifiers and classes for headers used in the GridSpot
  open static var headers = Registry()

  /// A component struct used as configuration and data source for the GridSpot
  open var component: Component

  /// A configuration closure
  open var configure: ((SpotConfigurable) -> Void)? {
    didSet {
      guard let configure = configure else { return }
      for case let cell as SpotConfigurable in collectionView.visibleCells {
        configure(cell)
      }
    }
  }

  /// A CompositeDelegate for the GridSpot, used to access composite spots
  open weak var spotsCompositeDelegate: CompositeDelegate?

  /// A SpotsDelegate that is used for the GridSpot
  open weak var delegate: SpotsDelegate?

  /// A custom UICollectionViewFlowLayout
  open lazy var layout: CollectionLayout = CollectionLayout()

  /// A StateCache for the GridSpot
  open fileprivate(set) var stateCache: StateCache?

  /// Indicator to calculate the height based on content
  open var usesDynamicHeight = true

  /// A UICollectionView, used as the main UI component for a GridSpot
  open lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.isScrollEnabled = false

    return collectionView
  }()

  /// A required initializer to instantiate a GridSpot with a component.
  ///
  /// - parameter component: A component.
  ///
  /// - returns: An initialized grid spot with component.
  public required init(component: Component) {
    self.component = component
    super.init()

    registerDefault(view: GridSpotCell.self)
    registerComposite(view: GridComposite.self)
    registerAndPrepare()
    configureLayout()

    if GridSpot.views.composite == nil {
      GridSpot.views.composite =  Registry.Item.classType(GridComposite.self)
    }
  }

  /// A convenience init for initializing a Gridspot with a title and a kind.
  ///
  ///  - parameter title: A string that is used as a title for the GridSpot.
  ///  - parameter kind:  An identifier to determine which kind should be set on the Component.
  ///
  /// - returns: An initialized grid spot with computed component using title and kind.
  public convenience init(title: String = "", kind: String? = nil) {
    self.init(component: Component(title: title, kind: kind ?? "grid"))
  }

  /// Instantiate a GridSpot with a cache key.
  ///
  /// - parameter cacheKey: A unique cache key for the Spotable object
  ///
  /// - returns: An initialized grid spot.
  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)

    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache
  }

  /// A convenience initializer for GridSpot with base configuration.
  ///
  /// - parameter component:   A Component.
  /// - parameter top:         Top section inset.
  /// - parameter left:        Left section inset.
  /// - parameter bottom:      Bottom section inset.
  /// - parameter right:       Right section inset.
  /// - parameter itemSpacing: The item spacing used in the flow layout.
  /// - parameter lineSpacing: The line spacing used in the flow layout.
  ///
  /// - returns: An initialized grid spot with configured layout.
  public convenience init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0, lineSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    layout.minimumInteritemSpacing = itemSpacing
    layout.minimumLineSpacing = lineSpacing
  }

  /// Configure section insets and layout spacing for the UICollectionViewFlow using component meta data
  func configureLayout() {
    layout.sectionInset = UIEdgeInsets(
      top: component.meta(GridableMeta.Key.sectionInsetTop, Default.sectionInsetTop),
      left: component.meta(GridableMeta.Key.sectionInsetLeft, Default.sectionInsetLeft),
      bottom: component.meta(GridableMeta.Key.sectionInsetBottom, Default.sectionInsetBottom),
      right: component.meta(GridableMeta.Key.sectionInsetRight, Default.sectionInsetRight))
    layout.minimumInteritemSpacing = component.meta(GridableMeta.Key.minimumInteritemSpacing, Default.minimumInteritemSpacing)
    layout.minimumLineSpacing = component.meta(GridableMeta.Key.minimumLineSpacing, Default.minimumLineSpacing)
    collectionView.contentInset.left = component.meta(GridableMeta.Key.contentInsetLeft, Default.contentInsetLeft)
    collectionView.contentInset.right = component.meta(GridableMeta.Key.contentInsetRight, Default.contentInsetRight)
  }
}

extension GridSpot : UICollectionViewDataSource {

  /// Asks your data source object to provide a supplementary view to display in the collection view.
  /// A configured supplementary view object. You must not return nil from this method.
  ///
  /// - parameter collectionView: The collection view requesting this information.
  /// - parameter kind:           The kind of supplementary view to provide. The value of this string is defined by the layout object that supports the supplementary view.
  /// - parameter indexPath:      The index path that specifies the location of the new supplementary view.
  ///
  /// - returns: A configured supplementary view object.
  public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = component.header.isEmpty
      ? type(of: self).headers.defaultIdentifier
      : component.header

    let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: header, for: indexPath)
    (view as? Componentable)?.configure(component)

    return view
  }

  /// Asks the data source for the number of items in the specified section. (required)
  ///
  /// - parameter collectionView: An object representing the collection view requesting this information.
  /// - parameter section:        An index number identifying a section in collectionView. This index value is 0-based.
  ///
  /// - returns: The number of rows in section.
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return component.items.count
  }

  /// Asks the data source for the cell that corresponds to the specified item in the collection view. (required)
  ///
  /// - parameter collectionView: collectionView: An object representing the collection view requesting this information.
  /// - parameter indexPath:      The index path that specifies the location of the item.
  ///
  /// - returns: A configured cell object. You must not return nil from this method.
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    component.items[indexPath.item].index = indexPath.item

    let reuseIdentifier = identifier(at: indexPath)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    if let composite = cell as? Composable {
      let spots = spotsCompositeDelegate?.resolve(index, itemIndex: (indexPath as NSIndexPath).item)
      composite.configure(&component.items[indexPath.item], spots: spots)
    } else if let cell = cell as? SpotConfigurable {
      cell.configure(&component.items[indexPath.item])
      if component.items[indexPath.item].size.height == 0.0 {
        component.items[indexPath.item].size = cell.preferredViewSize
      }
      configure?(cell)
    }

    return cell
  }
}

extension GridSpot : UICollectionViewDelegate {

  /// Asks the delegate for the size of the specified item’s cell.
  ///
  /// - parameter collectionView: The collection view object displaying the flow layout.
  /// - parameter collectionViewLayout: The layout object requesting the information.
  /// - parameter indexPath: The index path of the item.
  ///
  /// - returns: The width and height of the specified item. Both values must be greater than 0.
  @objc(collectionView:layout:sizeForItemAtIndexPath:) public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return sizeForItem(at: indexPath)
  }

  /// Tells the delegate that the item at the specified index path was selected.
  ///
  /// - parameter collectionView: The collection view object that is notifying you of the selection change.
  /// - parameter indexPath: The index path of the cell that was selected.
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let item = item(at: indexPath) else { return }
    delegate?.didSelect(item: item, in: self)
  }

  /// Asks the delegate whether the item at the specified index path can be focused.
  ///
  /// - parameter collectionView: The collection view object requesting this information.
  /// - parameter indexPath:      The index path of an item in the collection view.
  ///
  /// - returns: YES if the item can receive be focused or NO if it can not.
  public func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
    return true
  }

  ///Asks the delegate whether a change in focus should occur.
  ///
  /// - parameter collectionView: The collection view object requesting this information.
  /// - parameter context:        The context object containing metadata associated with the focus change.
  /// This object contains the index path of the previously focused item and the item targeted to receive focus next. Use this information to determine if the focus change should occur.

  /// - returns: YES if the focus change should occur or NO if it should not.
  @available(iOS 9.0, *)
  public func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
    guard let indexPaths = collectionView.indexPathsForSelectedItems else { return true }
    return indexPaths.isEmpty
  }

  /// Perform animation before mutation
  ///
  /// - parameter spotAnimation: The animation that you want to apply
  /// - parameter withIndex: The index of the cell
  /// - parameter completion: A completion block that runs after applying the animation
  public func perform(_ spotAnimation: Animation, withIndex index: Int, completion: () -> Void) {
    guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0))
      else { completion(); return }

    let animation = CABasicAnimation()

    switch spotAnimation {
    case .top:
      animation.keyPath = "position.y"
      animation.toValue = -cell.frame.height
    case .bottom:
      animation.keyPath = "position.y"
      animation.toValue = cell.frame.height * 2
    case .left:
      animation.keyPath = "position.x"
      animation.toValue = -cell.frame.width - collectionView.contentOffset.x
    case .right:
      animation.keyPath = "position.x"
      animation.toValue = cell.frame.width + collectionView.frame.size.width + collectionView.contentOffset.x
    case .fade:
      animation.keyPath = "opacity"
      animation.toValue = 0.0
    case .middle:
      animation.keyPath = "transform.scale.y"
      animation.toValue = 0.0
    case .automatic:
      animation.keyPath = "transform.scale"
      animation.toValue = 0.0
    default:
      break
    }

    animation.duration = 0.3
    cell.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    cell.layer.add(animation, forKey: "Animation")
    completion()
  }
}

extension GridSpot: UICollectionViewDelegateFlowLayout {

  /// Asks the delegate for the spacing between successive rows or columns of a section.
  ///
  /// - parameter collectionView:       The collection view object displaying the flow layout.
  /// - parameter collectionViewLayout: The layout object requesting the information.
  /// - parameter section:              The index number of the section whose line spacing is needed.
  /// - returns: The minimum space (measured in points) to apply between successive lines in a section.
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    guard layout.scrollDirection == .horizontal else { return layout.sectionInset.bottom }

    return layout.minimumLineSpacing
  }

  /// Asks the delegate for the margins to apply to content in the specified section.
  ///
  /// - parameter collectionView:       The collection view object displaying the flow layout.
  /// - parameter collectionViewLayout: The layout object requesting the information.
  /// - parameter section:              The index number of the section whose insets are needed.
  ///
  /// - returns: The margins to apply to items in the section.
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    guard layout.scrollDirection == .horizontal else { return layout.sectionInset }

    let left = layout.minimumLineSpacing / 2
    let right = layout.minimumLineSpacing / 2

    return UIEdgeInsets(top: layout.sectionInset.top,
                        left: left,
                        bottom: layout.sectionInset.bottom,
                        right: right)
  }
}
