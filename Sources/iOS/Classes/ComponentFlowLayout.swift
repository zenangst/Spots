import UIKit

/// A custom flow layout used in GridComponent and CarouselComponent
open class ComponentFlowLayout: UICollectionViewFlowLayout {

  /// The content size for the Gridable object
  public var contentSize = CGSize.zero
  /// The y offset for the Gridable object
  open var yOffset: CGFloat?

  private var layoutAttributes: [UICollectionViewLayoutAttributes]?
  private(set) var cachedFrames = [CGRect]()

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
      let component = delegate.component,
      let layout = component.model.layout
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
      contentSize = .zero

      if let firstItem = component.model.items.first {
        contentSize.height = (firstItem.size.height + minimumLineSpacing) * CGFloat(layout.itemsPerRow)

        if component.model.items.count % layout.itemsPerRow == 1 {
          contentSize.width += firstItem.size.width + minimumLineSpacing
        }
      }

      contentSize.height -= minimumLineSpacing

      for (index, item) in component.model.items.enumerated() {
        guard indexEligibleForItemsPerRow(index: index, itemsPerRow: layout.itemsPerRow) else {
          continue
        }

        contentSize.width += item.size.width + minimumInteritemSpacing
      }

      if layout.infiniteScrolling {
        let dataSourceCount = collectionView?.numberOfItems(inSection: 0) ?? 0

        if dataSourceCount > component.model.items.count {
          for index in component.model.items.count..<dataSourceCount {
            let indexPath = IndexPath(item: index - component.model.items.count, section: 0)
            contentSize.width += component.sizeForItem(at: indexPath).width + minimumInteritemSpacing
          }

          contentSize.width += CGFloat(layout.inset.right)
        }
      }

      contentSize.height += component.headerHeight
      contentSize.height += component.footerHeight
      contentSize.width -= minimumInteritemSpacing
      contentSize.width += CGFloat(layout.inset.left + layout.inset.right)

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
      let component = dataSource.component,
      let layout = component.model.layout
      else {
        return nil
    }

    var attributes = [UICollectionViewLayoutAttributes]()
    var nextX: CGFloat = sectionInset.left
    var nextY: CGFloat = 0.0

    if let newAttributes = self.layoutAttributes {
      for (index, attribute) in newAttributes.enumerated() {
        guard let itemAttribute = attribute.copy() as? UICollectionViewLayoutAttributes
          else {
            continue
        }

        if layout.infiniteScrolling {
          if index >= component.model.items.count {
            itemAttribute.size = component.sizeForItem(at: IndexPath(item: index - component.model.items.count, section: 0))
          } else {
            itemAttribute.size = component.sizeForItem(at: itemAttribute.indexPath)
          }
        } else {
          itemAttribute.size = component.sizeForItem(at: itemAttribute.indexPath)
        }

        if scrollDirection == .horizontal {
          if layout.itemsPerRow > 1 {
            if itemAttribute.indexPath.item % layout.itemsPerRow == 0 {
              itemAttribute.frame.origin.y = component.headerHeight + sectionInset.top
            } else {
              itemAttribute.frame.origin.y = nextY
            }
          } else {
            itemAttribute.frame.origin.y = component.headerHeight + sectionInset.top
          }

          itemAttribute.frame.origin.x = nextX

          if indexEligibleForItemsPerRow(index: itemAttribute.indexPath.item, itemsPerRow: layout.itemsPerRow) {
            nextX += itemAttribute.size.width + minimumInteritemSpacing
            nextY = component.headerHeight + sectionInset.top
          } else {
            nextY = itemAttribute.frame.maxY + minimumLineSpacing
          }
        } else {
          itemAttribute.frame.origin.y += component.headerHeight
        }

        attributes.append(itemAttribute)

        if let itemAttributeCopy = itemAttribute.copy() as? UICollectionViewLayoutAttributes {
          if index >= cachedFrames.count {
            cachedFrames.append(itemAttribute.frame)
          } else {
            cachedFrames[index] = itemAttribute.frame
          }
        }
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

  /// Check if the current index is eligible for performing itemsPerRow calculations.
  /// If `itemsPerRow` is set to 1, it will always return `true`.
  ///
  /// - Parameters:
  ///   - index: The index that should be checked if it is eligible or not.
  ///   - itemsPerRow: The amount of items that should appear on per row, see `itemsPerRow on `Layout`.
  /// - Returns: True if `index` is equal to the remainder of `itemsPerRow` or `itemsPerRow` is set to 1.
  private func indexEligibleForItemsPerRow(index: Int, itemsPerRow: Int) -> Bool {
    return itemsPerRow == 1 || index % itemsPerRow == itemsPerRow - 1
  }
}
