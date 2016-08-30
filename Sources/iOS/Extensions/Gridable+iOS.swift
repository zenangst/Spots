import UIKit
import Sugar
import Brick

extension Gridable {

  /**
   Initializes a Gridable container and configures the Spot with the provided component and optional layout properties.

   - Parameter component: A Component model
   - Parameter top: The top UIEdgeInset for the layout
   - Parameter left: The left UIEdgeInset for the layout
   - Parameter bottom: The bottom UIEdgeInset for the layout
   - Parameter right: The right UIEdgeInset for the layout
   - Parameter itemSpacing: The minimumInteritemSpacing for the layout
   */
  public init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = EdgeInsets(top: top, left: left, bottom: bottom, right: right)
    layout.minimumInteritemSpacing = itemSpacing
  }

  /**
   Asks the data source for the size of an item in a particular location.

   - Parameter indexPath: The index path of the
   - Returns: Size of the object at index path as CGSize
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

  public func prepareItems() {
    component.items.enumerate().forEach { (index: Int, _) in
      configureItem(index, usesViewSize: true)
      if component.span > 0 {
        component.items[index].size.width = UIScreen.mainScreen().bounds.size.width / CGFloat(component.span)
      }
    }
  }

  /**
   - Parameter size: A CGSize to set the width and height of the collection view
   */
  public func layout(size: CGSize) {
    layout.invalidateLayout()
    collectionView.frame.size.width = size.width
    collectionView.frame.size.height = layout.collectionViewContentSize().height
  }

  // MARK: - Spotable

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
        self.collectionView.registerClass(classType, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: identifier)
      case .nib(let nib):
        self.collectionView.registerNib(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: identifier)
      }
    }
  }

  public static func register(header header: View.Type, identifier: StringConvertible) {
    self.headers.storage[identifier.string] = Registry.Item.classType(header)
  }

  public static func register(header nib: Nib, identifier: StringConvertible) {
    self.headers.storage[identifier.string] = Registry.Item.nib(nib)
  }

  public static func register(defaultHeader header: View.Type) {
    self.headers.storage[self.views.defaultIdentifier] = Registry.Item.classType(header)
  }
}
