import UIKit

/// A custom flow layout used in GridComponent and CarouselComponent
open class GridableLayout: UICollectionViewFlowLayout {

  /// The content size for the Gridable object
  public var contentSize = CGSize.zero
  /// The y offset for the Gridable object
  open var yOffset: CGFloat?

  private var layoutAttributes: [UICollectionViewLayoutAttributes]?

  // Subclasses must override this method and use it to return the width and height of the collection view’s content. These values represent the width and height of all the content, not just the content that is currently visible. The collection view uses this information to configure its own content size to facilitate scrolling.
  open override var collectionViewContentSize: CGSize {
    guard let delegate = collectionView?.delegate as? Delegate,
      let component = delegate.component
      else {
        return CGSize.zero
    }

    if scrollDirection != .horizontal {
      contentSize.height = super.collectionViewContentSize.height
      contentSize.height += component.headerHeight
      contentSize.height += component.footerHeight
    }

    return contentSize
  }

  /// The collection view calls -prepareLayout once at its first layout as the first message to the layout instance.
  /// The collection view calls -prepareLayout again after layout is invalidated and before requerying the layout information.
  /// Subclasses should always call super if they override.
  open override func prepare() {
    guard let delegate = collectionView?.delegate as? Delegate,
      let component = delegate.component
      else {
        return
    }

    super.prepare()

    var layoutAttributes = [UICollectionViewLayoutAttributes]()

    for index in 0..<(collectionView?.numberOfItems(inSection: 0) ?? 0) {
      if let itemAttribute = self.layoutAttributesForItem(at: IndexPath(item: index, section: 0)) {
        layoutAttributes.append(itemAttribute)
      }
    }

    self.layoutAttributes = layoutAttributes

    switch scrollDirection {
    case .horizontal:
      guard let firstItem = component.model.items.first else {
        return
      }

      contentSize.width = component.model.items.reduce(0, { $0 + floor($1.size.width) })
      contentSize.width += minimumInteritemSpacing * CGFloat(component.model.items.count - 1)

      contentSize.height = firstItem.size.height
      contentSize.height += component.headerHeight
      contentSize.height += component.footerHeight

      if let componentLayout = component.model.layout {
        contentSize.height += CGFloat(componentLayout.inset.top + componentLayout.inset.bottom)

        #if os(iOS)
        if let pageControl = collectionView?.backgroundView?.subviews.filter({ $0 is UIPageControl }).first {
          contentSize.height += pageControl.frame.size.height
        }
        #endif
      }
    case .vertical:
      contentSize.width = component.view.frame.width - component.view.contentInset.left - component.view.contentInset.right
      contentSize.height = super.collectionViewContentSize.height
      contentSize.height += component.headerHeight
      contentSize.height += component.footerHeight
    }
  }

  /// Returns the layout attributes for all of the cells and views in the specified rectangle.
  ///
  /// - parameter rect: The rectangle (specified in the collection view’s coordinate system) containing the target views.
  ///
  /// - returns: An array of layout attribute objects containing the layout information for the enclosed items and views. The default implementation of this method returns nil.
  open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let collectionView = collectionView,
      let dataSource = collectionView.dataSource as? DataSource,
      let component = dataSource.component
      else {
        return nil
    }

    var attributes = [UICollectionViewLayoutAttributes]()

    if let newAttributes = self.layoutAttributes {
      var offset: CGFloat = sectionInset.left
      for attribute in newAttributes {
        guard let itemAttribute = attribute.copy() as? UICollectionViewLayoutAttributes
          else {
            continue
        }

        itemAttribute.size = component.sizeForItem(at: itemAttribute.indexPath)

        if scrollDirection == .horizontal {
          itemAttribute.frame.origin.y = component.headerHeight + sectionInset.top
          itemAttribute.frame.origin.x = offset
          offset += itemAttribute.size.width + minimumInteritemSpacing
        } else {
          itemAttribute.frame.origin.y += component.headerHeight
        }

        attributes.append(itemAttribute)
      }
    }

    if let y = yOffset, component.headerHeight > 0.0 {
      collectionView.frame.origin.y = y
    }

    return attributes
  }

  /// Asks the layout object if the new bounds require a layout update.
  ///
  /// - parameter newBounds: The new bounds of the collection view.
  ///
  /// - returns: Always returns true
  open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return newBounds.size.height >= contentSize.height
  }
}
