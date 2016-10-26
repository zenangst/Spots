import UIKit
import Brick

/// A CarouselSpot, a collection view based Spotable object that lays out its items in a horizontal order
open class CarouselSpot: NSObject, Gridable {

  /**
   *  A struct that holds keys that is used when mapping meta data to configuration methods
   */
  public struct Key {
    /// Dynamic span key used when looking up meta properties
    public static let dynamicSpan = "dynamic-span"
  }

  /**
   *  A struct with default values for the CarouselSpot
   */
  public struct Default {
    /// Default dynamicSpan value
    public static var dynamicSpan: Bool = false
    /// Default section inset top
    public static var sectionInsetTop: CGFloat = 0.0
    /// Default section inset left
    public static var sectionInsetLeft: CGFloat = 0.0
    /// Default section inset right
    public static var sectionInsetRight: CGFloat = 0.0
    /// Default section inset bottom
    public static var sectionInsetBottom: CGFloat = 0.0
    /// Default default minimum interitem spacing
    public static var minimumInteritemSpacing: CGFloat = 0.0
    /// Default minimum line spacing
    public static var minimumLineSpacing: CGFloat = 0.0
    /// Default left section inset
    public static var contentInsetLeft: CGFloat = 0.0
    /// Default right section inset
    public static var contentInsetRight: CGFloat = 0.0
  }

  /// A boolean value that affects the sizing of items when using span, if enabled and the item count is less than the span, the CarouselSpot will even out the space between the items to align them
  open var dynamicSpan = false

  /// Indicator to calculate the height based on content
  open var usesDynamicHeight = true

  /// A Registry object that holds identifiers and classes for cells used in the CarouselSpot
  open static var views: Registry = Registry()

  /// A configuration closure that is run in setup(_:)
  open static var configure: ((_ view: UICollectionView, _ layout: UICollectionViewFlowLayout) -> Void)?

  /// A Registry object that holds identifiers and classes for headers used in the CarouselSpot
  open static var headers = Registry()

  /// A StateCache for the CarouselSpot
  open fileprivate(set) var stateCache: StateCache?

  /// A component struct used as configuration and data source for the CarouselSpot
  open var component: Component {
    willSet(value) {
      #if os(iOS)
        dynamicSpan = component.meta(Key.dynamicSpan, Default.dynamicSpan)
        if component.items.count > 1 && component.span > 0.0 {
          pageControl.numberOfPages = Int(floor(Double(component.items.count) / component.span))
        }
      #endif
    }
  }

  #if os(iOS)
  /// A boolean value that configures the collection views pagination
  open var paginate = false {
    willSet(newValue) {
      if component.span == 1 {
        collectionView.isPagingEnabled = newValue
      }
    }
  }

  /// Determines how the CarouselSpot should handle pagination, if enabled, it will snap to each item in the carousel
  open var paginateByItem: Bool = false
  #endif

  /// A boolean value that determines if the CarouselSpot should show a page indicator
  open var pageIndicator: Bool = false {
    willSet(value) {
      if value {
        pageControl.frame.size.width = backgroundView.frame.width
        collectionView.backgroundView?.addSubview(pageControl)
      } else {
        pageControl.removeFromSuperview()
      }
    }
  }

  /// A configuration closure
  open var configure: ((SpotConfigurable) -> Void)? {
    didSet {
      guard let configure = configure else { return }
      for case let cell as SpotConfigurable in collectionView.visibleCells {
        configure(cell)
      }
    }
  }

  /// A CarouselScrollDelegate, used when a CarouselSpot scrolls
  open weak var carouselScrollDelegate: CarouselScrollDelegate?

  /// A CompositeDelegate for the CarouselSpot, used to access composite spots
  open weak var spotsCompositeDelegate: CompositeDelegate?

  /// A SpotsDelegate that is used for the CarouselSpot
  open weak var delegate: SpotsDelegate?

  /// A UIPageControl, enable by setting pageIndicator to true
  open lazy var pageControl: UIPageControl = {
    let pageControl = UIPageControl()
    pageControl.frame.size.height = 22
    pageControl.pageIndicatorTintColor = UIColor.lightGray
    pageControl.currentPageIndicatorTintColor = UIColor.gray

    return pageControl
  }()

  /// A custom UICollectionViewFlowLayout
  open lazy var layout: CollectionLayout = {
    let layout = GridableLayout()
    layout.scrollDirection = .horizontal

    return layout
  }()

  /// A UICollectionView, used as the main UI component for a CarouselSpot
  open lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.alwaysBounceHorizontal = true

    return collectionView
  }()

  /// The collection views background view
  open lazy var backgroundView = UIView()

  /// A required initializer to instantiate a CarouselSpot with a component.
  ///
  /// - parameter component: A component
  ///
  /// - returns: An initialized carousel spot.
  public required init(component: Component) {
    self.component = component
    super.init()
    registerDefault(view: CarouselSpotCell.self)
    registerComposite(view: CarouselComposite.self)
    registerDefaultHeader(header: CarouselSpotHeader.self)
    configureLayout()
    configureCollectionView()
  }

  /// A convenience initializer for CarouselSpot with base configuration.
  ///
  /// - parameter component:   A Component.
  /// - parameter top:         Top section inset.
  /// - parameter left:        Left section inset.
  /// - parameter bottom:      Bottom section inset.
  /// - parameter right:       Right section inset.
  /// - parameter itemSpacing: The item spacing used in the flow layout.
  /// - parameter lineSpacing: The line spacing used in the flow layout.
  ///
  /// - returns: An initialized carousel spot with configured layout.
  public convenience init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0, lineSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    layout.minimumInteritemSpacing = itemSpacing
    layout.minimumLineSpacing = lineSpacing
  }

  /// Instantiate a CarouselSpot with a cache key.
  ///
  /// - parameter cacheKey: A unique cache key for the Spotable object.
  ///
  /// - returns: An initialized carousel spot.
  public convenience init(cacheKey: String) {
    let stateCache = StateCache(key: cacheKey)
    self.init(component: Component(stateCache.load()))
    self.stateCache = stateCache
  }

  func configureCollectionView() {
    register()
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundView = backgroundView
  }

  /// Setup Spotable component with base size
  ///
  /// - parameter size: The size of the superview
  open func setup(_ size: CGSize) {
    collectionView.frame.size = size

    if collectionView.contentSize.height > 0 {
      collectionView.frame.size.height = collectionView.contentSize.height
    } else {
      collectionView.frame.size.height = component.items.sorted(by: { $0.size.height > $1.size.height }).first?.size.height ?? 0

      if collectionView.frame.size.height > 0 {
        collectionView.frame.size.height += layout.sectionInset.top + layout.sectionInset.bottom
      }
    }

    #if os(iOS)
      if let paginate = component.meta("paginate", type: Bool.self) {
        self.paginate = paginate
      }

      if let pageIndicator = component.meta("paginate", type: Bool.self) {
        self.pageIndicator = pageIndicator
      }
    #endif

    if !component.header.isEmpty {
      let resolve = type(of: self).headers.make(component.header)
      layout.headerReferenceSize.width = collectionView.frame.size.width
      layout.headerReferenceSize.height = resolve?.view?.frame.size.height ?? 0.0
    }

    CarouselSpot.configure?(collectionView, layout)

    collectionView.frame.size.height += layout.headerReferenceSize.height

    guard pageIndicator else { return }
    layout.sectionInset.bottom = layout.sectionInset.bottom + pageControl.frame.size.height
    collectionView.frame.size.height += layout.sectionInset.top + layout.sectionInset.bottom
    pageControl.frame.origin.y = collectionView.frame.size.height - pageControl.frame.size.height
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
    dynamicSpan = component.meta(Key.dynamicSpan, false)
    collectionView.contentInset.left = component.meta(GridableMeta.Key.contentInsetLeft, Default.contentInsetLeft)
    collectionView.contentInset.right = component.meta(GridableMeta.Key.contentInsetRight, Default.contentInsetRight)
  }

  /// Register default header for the CarouselSpot
  ///
  /// - parameter view: A header view
  func registerDefaultHeader(header view: View.Type) {
    guard type(of: self).headers.storage[type(of: self).headers.defaultIdentifier] == nil else { return }
    type(of: self).headers.defaultItem = Registry.Item.classType(view)
  }
}

extension CarouselSpot : UICollectionViewDataSource {

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

extension CarouselSpot : UICollectionViewDelegate {

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
}

extension CarouselSpot: UICollectionViewDelegateFlowLayout {

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

/// A scroll view extension on CarouselSpot to handle scrolling specifically for this object.
extension CarouselSpot: UIScrollViewDelegate {

  /// A method that handles what type of scrollling the CarouselSpot should use when pagination is enabled.
  /// It can snap to the nearest item or scroll page by page.
  fileprivate func paginatedEndScrolling() {
    var currentCellOffset = collectionView.contentOffset
    #if os(iOS)
      if paginateByItem {
        currentCellOffset.x += collectionView.frame.size.width / 2
      } else {
        if pageControl.currentPage == 0 {
          currentCellOffset.x = collectionView.frame.size.width / 2
        } else {
          currentCellOffset.x = (collectionView.frame.size.width * CGFloat(pageControl.currentPage)) + collectionView.frame.size.width / 2
          currentCellOffset.x += layout.sectionInset.left * CGFloat(pageControl.currentPage)
        }
      }
    #endif

    if let indexPath = collectionView.indexPathForItem(at: currentCellOffset) {
      collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    } else {
      currentCellOffset.x += layout.sectionInset.left
      if let indexPath = collectionView.indexPathForItem(at: currentCellOffset) {
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
      }
    }
  }

  /// Tells the delegate when the user scrolls the content view within the receiver.
  ///
  /// - parameter scrollView: The scroll-view object in which the scrolling occurred.
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    carouselScrollDelegate?.didScroll(in: self)
  }

  #if os(iOS)
  /// Tells the delegate when dragging ended in the scroll view.
  ///
  /// - parameter scrollView: The scroll-view object that finished scrolling the content view.
  /// - parameter decelerate: true if the scrolling movement will continue, but decelerate, after a touch-up gesture during a dragging operation.
  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard paginate else { return }
    paginatedEndScrolling()
  }

  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    carouselScrollDelegate?.didEndScrollingAnimated(in: self)
  }

  #endif

  /// Tells the delegate when the user finishes scrolling the content.
  ///
  /// - parameter scrollView:          The scroll-view object where the user ended the touch.
  /// - parameter velocity:            The velocity of the scroll view (in points) at the moment the touch was released.
  /// - parameter targetContentOffset: The expected offset when the scrolling action decelerates to a stop.
  public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    #if os(iOS)
      guard paginate else { return }
    #endif

    let pageWidth: CGFloat = collectionView.frame.size.width
    let currentOffset = scrollView.contentOffset.x
    let targetOffset = targetContentOffset.pointee.x

    var newTargetOffset: CGFloat = targetOffset > currentOffset
      ? ceil(currentOffset / pageWidth) * pageWidth
      : floor(currentOffset / pageWidth) * pageWidth

    if newTargetOffset > scrollView.contentSize.width {
      newTargetOffset = scrollView.contentSize.width
    } else if newTargetOffset < 0 {
      newTargetOffset = 0
    }

    let index: Int = Int(floor(newTargetOffset * CGFloat(items.count) / scrollView.contentSize.width))

    if index >= 0 && index <= items.count {
      carouselScrollDelegate?.didEndScrolling(in: self, item: items[index])
    }

    let floatIndex = ceil(CGFloat(index) / CGFloat(component.span))

    #if os(iOS)
      pageControl.currentPage = Int(floatIndex)
    #endif

    paginatedEndScrolling()
  }

  /// Scroll to a specific item based on predicate.
  ///
  /// - parameter predicate: A predicate closure to determine which item to scroll to
  public func scrollTo(_ predicate: (Item) -> Bool) {
    if let index = items.index(where: predicate) {
      let pageWidth: CGFloat = collectionView.frame.size.width - layout.sectionInset.right
        + layout.sectionInset.left

      collectionView.setContentOffset(CGPoint(x: pageWidth * CGFloat(index), y:0), animated: true)
    }
  }
}
