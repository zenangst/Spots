import UIKit

/// A custom flow layout used in GridComponent and CarouselComponent
open class ComponentFlowLayout: UICollectionViewFlowLayout {

  enum AnimationType {
    case insert, delete, move
  }

  /// The content size for the Gridable object
  public var contentSize = CGSize.zero
  /// The y offset for the Gridable object
  open var yOffset: CGFloat?

  var animation: Animation?
  private var indexPathsToAnimate = [IndexPath]()
  private var indexPathsToMove = [IndexPath]()
  private var layoutAttributes: [UICollectionViewLayoutAttributes]?
  private(set) var cachedFrames = [CGRect]()

  // Subclasses must override this method and use it to return the width and height of the collection view’s content. These values represent the width and height of all the content, not just the content that is currently visible. The collection view uses this information to configure its own content size to facilitate scrolling.
  open override var collectionViewContentSize: CGSize {
    guard let delegate = collectionView?.delegate as? Delegate,
      let component = delegate.component
      else {
        return .zero
    }

    guard !component.model.items.isEmpty, !component.model.layout.showEmptyComponent else {
      return .zero
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
      contentSize = .zero

      if let firstItem = component.model.items.first {
        contentSize.height = (firstItem.size.height + minimumLineSpacing) * CGFloat(component.model.layout.itemsPerRow)

        if component.model.items.count % component.model.layout.itemsPerRow == 1 {
          contentSize.width += firstItem.size.width + minimumLineSpacing
        }
      }

      contentSize.height -= minimumLineSpacing

      for (index, item) in component.model.items.enumerated() {
        guard indexEligibleForItemsPerRow(index: index, itemsPerRow: component.model.layout.itemsPerRow) else {
          continue
        }

        contentSize.width += item.size.width + minimumInteritemSpacing
      }

      if component.model.layout.infiniteScrolling {
        let dataSourceCount = collectionView?.numberOfItems(inSection: 0) ?? 0

        if dataSourceCount > component.model.items.count {
          for index in component.model.items.count..<dataSourceCount {
            let indexPath = IndexPath(item: index - component.model.items.count, section: 0)
            contentSize.width += component.sizeForItem(at: indexPath).width + minimumInteritemSpacing
          }

          contentSize.width += CGFloat(component.model.layout.inset.right)
        }
      }

      contentSize.height += component.headerHeight
      contentSize.height += component.footerHeight
      contentSize.height += CGFloat(component.model.layout.inset.top + component.model.layout.inset.bottom)
      contentSize.width -= minimumInteritemSpacing
      contentSize.width += CGFloat(component.model.layout.inset.left + component.model.layout.inset.right)

      #if os(iOS)
        if let pageControl = collectionView?.backgroundView?.subviews.filter({ $0 is UIPageControl }).first {
          contentSize.height += pageControl.frame.size.height
        }
      #endif
    case .vertical:
      contentSize.width = component.view.frame.width - component.view.contentInset.left - component.view.contentInset.right
      contentSize.height = super.collectionViewContentSize.height
      contentSize.height += component.headerHeight
      contentSize.height += component.footerHeight
    }

    component.model.size = contentSize
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
    var nextX: CGFloat = sectionInset.left
    var nextY: CGFloat = 0.0

    if let newAttributes = self.layoutAttributes {
      for (index, attribute) in newAttributes.enumerated() {
        guard let itemAttribute = attribute.copy() as? UICollectionViewLayoutAttributes
          else {
            continue
        }

        if component.model.layout.infiniteScrolling {
          if index >= component.model.items.count {
            itemAttribute.size = component.sizeForItem(at: IndexPath(item: index - component.model.items.count, section: 0))
          } else {
            itemAttribute.size = component.sizeForItem(at: itemAttribute.indexPath)
          }
        } else {
          itemAttribute.size = component.sizeForItem(at: itemAttribute.indexPath)
        }

        if scrollDirection == .horizontal {
          if component.model.layout.itemsPerRow > 1 {
            if itemAttribute.indexPath.item % component.model.layout.itemsPerRow == 0 {
              itemAttribute.frame.origin.y = component.headerHeight + sectionInset.top
            } else {
              itemAttribute.frame.origin.y = nextY
            }
          } else {
            itemAttribute.frame.origin.y = component.headerHeight + sectionInset.top
          }

          itemAttribute.frame.origin.x = nextX

          if indexEligibleForItemsPerRow(index: itemAttribute.indexPath.item, itemsPerRow: component.model.layout.itemsPerRow) {
            nextX += itemAttribute.size.width + minimumInteritemSpacing
            nextY = component.headerHeight + sectionInset.top
          } else {
            nextY = itemAttribute.frame.maxY + minimumLineSpacing
          }

          attributes.append(itemAttribute)
        } else {
          itemAttribute.frame.origin.y += component.headerHeight
          // Only add item attributes if the item frame insects the rect passed into the method.
          // This removes unwanted computation when a collection view scrolls.
          // Note that this only applies to vertical components.
          if itemAttribute.frame.intersects(rect) {
            attributes.append(itemAttribute)
          }
        }

        if index >= cachedFrames.count {
          cachedFrames.append(itemAttribute.frame)
        } else {
          cachedFrames[index] = itemAttribute.frame
        }
      }
    }

    if let y = yOffset, component.headerHeight > 0.0 {
      collectionView.frame.origin.y = y
    }

    return attributes
  }

  open override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) else {
      return nil
    }

    guard indexPathsToAnimate.contains(itemIndexPath) else {
      if let index = indexPathsToMove.index(of: itemIndexPath) {
        indexPathsToMove.remove(at: index)
        attributes.alpha = 1.0
        return attributes
      }
      return nil
    }

    if let index = indexPathsToAnimate.index(of: itemIndexPath) {
      indexPathsToAnimate.remove(at: index)
    }

    guard let animation = animation else {
      return nil
    }

    applyAnimation(animation, type: .insert, to: attributes)

    return attributes
  }

  open override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) else {
      return nil
    }

    guard indexPathsToAnimate.contains(itemIndexPath) else {
      if let index = indexPathsToMove.index(of: itemIndexPath) {
        indexPathsToMove.remove(at: index)
        attributes.alpha = 1.0
        return attributes
      }
      return nil
    }

    if let index = indexPathsToAnimate.index(of: itemIndexPath) {
      indexPathsToAnimate.remove(at: index)
    }

    guard let animation = animation else {
      return nil
    }

    applyAnimation(animation, type: .delete, to: attributes)

    return attributes
  }

  open override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
    super.prepare(forCollectionViewUpdates: updateItems)

    var currentIndexPath: IndexPath?
    for updateItem in updateItems {
      switch updateItem.updateAction {
      case .insert:
        currentIndexPath = updateItem.indexPathAfterUpdate
      case .delete:
        currentIndexPath = updateItem.indexPathBeforeUpdate
      case .move:
        currentIndexPath = nil

        indexPathsToMove.append(updateItem.indexPathBeforeUpdate!)
        indexPathsToMove.append(updateItem.indexPathAfterUpdate!)
      default:
        currentIndexPath = nil
      }

      if let indexPath = currentIndexPath {
        indexPathsToAnimate.append(indexPath)
      }
    }
  }

  /// This method performs a small mutation to the attributes in order to make the first item
  /// in the row animate properly.
  ///
  /// - Parameters:
  ///   - type: The type of operation that is being performed, can be `.insert`, `.delete` or
  ///           `.move`
  ///   - attributes: The attributes for the collection view item that the collection view is
  ///                 modifying.
  fileprivate func applyAnimationFix(_ type: ComponentFlowLayout.AnimationType, _ attributes: UICollectionViewLayoutAttributes) {
    // Add y offset to the first item in the row, otherwise it won't animate.
    if type == .insert && attributes.frame.origin.x == sectionInset.left {
      // To make it more accurate we can use a smaller offset for items that are not the
      // first item in the first row.
      let offset: CGFloat = attributes.indexPath.item > 0 ? 0.1 : sectionInset.left
      attributes.center = .init(x: attributes.center.x, y: attributes.center.y - offset)
    }
  }

  /// Apply animation to current operation
  ///
  /// - Parameters:
  ///   - animation: The animation that should be applied for the operation. See `Animation`
  ///                more information about the animations that are currently supported.
  ///   - type: The type of operation that is being performed, can be `.insert`, `.delete` or
  ///           `.move`
  ///   - attributes: The attributes for the collection view item that the collection view is
  ///                 modifying.
  private func applyAnimation(_ animation: Animation, type: AnimationType, to attributes: UICollectionViewLayoutAttributes) {
    guard let collectionView = collectionView,
      let delegate = collectionView.delegate as? Delegate,
      let component = delegate.component else {
        return
    }

    if type == .move {
      return
    }

    let excludedAnimationTypes: [Animation] = [.top, .bottom]

    if !excludedAnimationTypes.contains(animation) {
      applyAnimationFix(type, attributes)
    }

    switch animation {
    case .fade:
      attributes.alpha = 0.0
    case .right:
      attributes.center.x = type == .insert ? collectionView.bounds.minX : collectionView.bounds.maxX
    case .left:
      attributes.center.x = type == .insert ? collectionView.bounds.maxX : collectionView.bounds.minX
    case .top:
      attributes.center.y += attributes.frame.size.height
    case .bottom:
      if attributes.frame.origin.x == sectionInset.left {
        attributes.center = .init(x: attributes.frame.midX,
                                  y: attributes.center.y + attributes.frame.size.height)
      } else {
        attributes.center.y += attributes.frame.size.height
      }
    case .none:
      attributes.alpha = 1.0
    case .middle:
      switch type {
      case .insert:
        attributes.frame.origin = .init(x: collectionView.bounds.midX,
                                        y: collectionView.bounds.midY)
      default:
        break
      }
    case .automatic:
      switch type {
      case .insert:
        if component.model.items.count == 1 {
          attributes.alpha = 0.0
          return
        }
      case .delete:
        if component.model.items.isEmpty {
          attributes.alpha = 0.0
          return
        }
      default:
        break
      }

      attributes.zIndex = -1

      if type == .insert {
        attributes.alpha = 0.0
      }

      attributes.center = .init(x: attributes.center.x,
                                y: attributes.center.y - attributes.frame.size.height)
    }
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
