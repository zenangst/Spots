import UIKit
import Brick

extension Gridable {

  /**
   Initializes a Gridable container and configures the Spot with the provided component and optional layout properties.

   - parameter component: A Component model
   - parameter top: The top UIEdgeInset for the layout
   - parameter left: The left UIEdgeInset for the layout
   - parameter bottom: The bottom UIEdgeInset for the layout
   - parameter right: The right UIEdgeInset for the layout
   - parameter itemSpacing: The minimumInteritemSpacing for the layout
   */
  public init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = EdgeInsets(top: top, left: left, bottom: bottom, right: right)
    layout.minimumInteritemSpacing = itemSpacing
  }

  /**
   Asks the data source for the size of an item in a particular location.

   - parameter indexPath: The index path of the
   - returns: Size of the object at index path as CGSize
   */
  public func sizeForItemAt(indexPath: NSIndexPath) -> CGSize {
    if component.span > 0 {
      component.items[indexPath.item].size.width = collectionView.frame.width / CGFloat(component.span) - layout.minimumInteritemSpacing
    }

    let width = (item(indexPath)?.size.width ?? 0) - collectionView.contentInset.left - layout.sectionInset.left - layout.sectionInset.right
    let height = item(indexPath)?.size.height ?? 0

    // Never return a negative width
    guard width > -1 else { return CGSize.zero }

    return CGSize(
      width: floor(width),
      height: ceil(height)
    )
  }

  /**
   Prepares all items in the Gridable object component
   */
  public func prepareItems() {
    component.items.enumerate().forEach { (index: Int, _) in
      configureItem(index, usesViewSize: true)
      if component.span > 0 {
        component.items[index].size.width = UIScreen.mainScreen().bounds.size.width / CGFloat(component.span)
      }
    }
  }

  /**
   - parameter size: A CGSize to set the width and height of the collection view
   */
  public func layout(size: CGSize) {
    prepareItems()
    layout.prepareLayout()
    layout.invalidateLayout()
    collectionView.frame.size.width = layout.collectionViewContentSize().width
    collectionView.frame.size.height = layout.collectionViewContentSize().height
  }

  // MARK: - Spotable

  /**
   Register all views in Registry on UICollectionView
   */
  public func register() {
    for (identifier, item) in self.dynamicType.views.storage {
      switch item {
      case .classType(let classType):
        self.collectionView.registerClass(classType, forCellWithReuseIdentifier: identifier)
      case .nib(let nib):
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: identifier)
      }
    }

    for (identifier, item) in self.dynamicType.headers.storage {
      switch item {
      case .classType(let classType):
        self.collectionView.registerClass(classType,
                                          forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                          withReuseIdentifier: identifier)
      case .nib(let nib):
        self.collectionView.registerNib(nib,
                                        forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                        withReuseIdentifier: identifier)
      }
    }
  }

  /**
   Add header view class to Registry

   - parameter header:     The view type that you want to register
   - parameter identifier: The identifier for the header
   */
  public static func register(header header: View.Type, identifier: StringConvertible) {
    self.headers.storage[identifier.string] = Registry.Item.classType(header)
  }

  /**
   Add header nib-based view class to Registry

   - parameter header:     The nib file that is used by the view
   - parameter identifier: The identifier for the nib-based header
   */
  public static func register(header nib: Nib, identifier: StringConvertible) {
    self.headers.storage[identifier.string] = Registry.Item.nib(nib)
  }

  /**
   Register a default header for the Gridable component

   - parameter defaultHeader: The default header class that should be used by the component
   */
  public static func register(defaultHeader header: View.Type) {
    self.headers.storage[self.views.defaultIdentifier] = Registry.Item.classType(header)
  }
}
