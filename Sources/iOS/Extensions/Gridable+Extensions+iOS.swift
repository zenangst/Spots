import UIKit
import Brick

extension Gridable {

  /// A computed CGFloat of the total height of all items inside of a component.
  public var computedHeight: CGFloat {
    guard usesDynamicHeight else {
      return self.view.frame.height
    }

    layout.prepare()

    var height = layout.collectionViewContentSize.height + layout.sectionInset.top + layout.sectionInset.bottom
    let superViewHeight = self.view.superview?.frame.size.height ?? UIScreen.main.bounds.height
    if height > superViewHeight {
      height = superViewHeight
    }

    return height
  }

  /// Initializes a Gridable container and configures the Spot with the provided component and optional layout properties.
  ///
  /// - parameter component: A Component model.
  /// - parameter top: The top UIEdgeInset for the layout.
  /// - parameter left: The left UIEdgeInset for the layout.
  /// - parameter bottom: The bottom UIEdgeInset for the layout.
  /// - parameter right: The right UIEdgeInset for the layout.
  /// - parameter itemSpacing: The minimumInteritemSpacing for the layout.
  public init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = EdgeInsets(top: top, left: left, bottom: bottom, right: right)
    layout.minimumInteritemSpacing = itemSpacing
  }

  /// Asks the data source for the size of an item in a particular location.
  ///
  /// - parameter indexPath: The index path of the
  ///
  /// - returns: Size of the object at index path as CGSize
  public func sizeForItem(at indexPath: IndexPath) -> CGSize {
    let width = (item(at: indexPath)?.size.width ?? 0)
    let height = item(at: indexPath)?.size.height ?? 0

    // Never return a negative width
    guard width > -1 else { return CGSize.zero }

    return CGSize(
      width: floor(width),
      height: ceil(height)
    )
  }

  /// Layout with size
  ///
  /// - parameter size: A CGSize to set the width and height of the collection view
  public func layout(_ size: CGSize) {
    if compositeSpots.isEmpty {
      prepareItems()
    }

    collectionView.collectionViewLayout.prepare()
    collectionView.collectionViewLayout.invalidateLayout()
    collectionView.frame.size.width = layout.collectionViewContentSize.width
    collectionView.frame.size.height = layout.collectionViewContentSize.height
  }

  /// Perform animation before mutation
  ///
  /// - parameter spotAnimation: The animation that you want to apply
  /// - parameter withIndex: The index of the cell
  /// - parameter completion: A completion block that runs after applying the animation
  public func perform(_ spotAnimation: Animation, withIndex index: Int, completion: () -> Void) {
    guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0))
      else {
        completion()
        return
    }

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

  // MARK: - Spotable

  /// Register all views in Registry on UICollectionView
  public func register() {
    for (identifier, item) in Configuration.views.storage {
      switch item {
      case .classType(_):
        self.collectionView.register(GridHeaderFooterWrapper.self,
                                     forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                     withReuseIdentifier: identifier)
        self.collectionView.register(GridHeaderFooterWrapper.self,
                                     forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                     withReuseIdentifier: identifier)
        self.collectionView.register(GridWrapper.self,
                                     forCellWithReuseIdentifier: identifier)
      case .nib(let nib):
        self.collectionView.register(nib, forCellWithReuseIdentifier: identifier)
      }
    }

    for (identifier, item) in type(of: self).views.storage {
      switch item {
      case .classType(let classType):
        self.collectionView.register(classType, forCellWithReuseIdentifier: identifier)
      case .nib(let nib):
        self.collectionView.register(nib, forCellWithReuseIdentifier: identifier)
      }
    }

    for (identifier, item) in type(of: self).headers.storage {
      switch item {
      case .classType(let classType):
        self.collectionView.register(classType,
                                          forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                          withReuseIdentifier: identifier)
      case .nib(let nib):
        self.collectionView.register(nib,
                                        forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                        withReuseIdentifier: identifier)
      }
    }
  }

  /// Add header view class to Registry
  ///
  /// - parameter header:     The view type that you want to register
  /// - parameter identifier: The identifier for the header
  public static func register(header: View.Type, identifier: StringConvertible) {
    self.headers.storage[identifier.string] = Registry.Item.classType(header)
  }

  /// Add header nib-based view class to Registry
  ///
  /// - parameter header:     The nib file that is used by the view
  /// - parameter identifier: The identifier for the nib-based header
  public static func register(header nib: Nib, identifier: StringConvertible) {
    self.headers.storage[identifier.string] = Registry.Item.nib(nib)
  }

  /// Register default header for the CarouselSpot
  ///
  /// - parameter view: A header view
  public func registerDefaultHeader(header view: View.Type) {
    guard type.headers.storage[type.headers.defaultIdentifier] == nil else { return }
    type.headers.defaultItem = Registry.Item.classType(view)
  }

  ///Register a default header for the Gridable component
  ///
  /// - parameter defaultHeader: The default header class that should be used by the component
  public static func register(defaultHeader header: View.Type) {
    self.headers.storage[self.views.defaultIdentifier] = Registry.Item.classType(header)
    self.headers.defaultItem = Registry.Item.classType(header)
  }

#if os(iOS)
  public func beforeUpdate() {
    CATransaction.begin()
  }

  public func afterUpdate() {
    CATransaction.commit()
  }
#endif

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

  /// Scrolls the collection view contents until the specified item is visible.
  ///
  /// - parameter index: The index path of the item to scroll into view.
  /// - parameter position: An option that specifies where the item should be positioned when scrolling finishes.
  /// - parameter animated: Specify true to animate the scrolling behavior or false to adjust the scroll view’s visible content immediately.
  public func scrollTo(index: Int, position: UICollectionViewScrollPosition = .centeredHorizontally, animated: Bool = true) {
    collectionView.scrollToItem(at: IndexPath(item: index, section: 0),
                                     at: position, animated: animated)
  }
}
