import Cocoa

public class ComponentFlowLayout: FlowLayout {

  enum AnimationType {
    case insert, delete, move
  }

  var animation: Animation?
  public var contentSize = CGSize.zero
  private var indexPathsToAnimate = [IndexPath]()
  private var indexPathsToMove = [IndexPath]()
  private var layoutAttributes: [NSCollectionViewLayoutAttributes]?

  open override var collectionViewContentSize: CGSize {
    if scrollDirection != .horizontal {
      contentSize.height = super.collectionViewContentSize.height
    }

    return contentSize
  }

  open override func prepare() {
    guard let delegate = collectionView?.delegate as? Delegate,
      let component = delegate.component,
      let layout = component.model.layout
      else {
        return
    }

    super.prepare()

    var layoutAttributes = [NSCollectionViewLayoutAttributes]()

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
        contentSize.height = firstItem.size.height * CGFloat(layout.itemsPerRow)

        if component.model.items.count % layout.itemsPerRow == 1 {
          contentSize.width += firstItem.size.width + minimumLineSpacing
          contentSize.height += CGFloat(layout.lineSpacing)
        }
      }

      for (index, item) in component.model.items.enumerated() {
        guard indexEligibleForItemsPerRow(index: index, itemsPerRow: layout.itemsPerRow) else {
          continue
        }

        contentSize.width += item.size.width + minimumInteritemSpacing
      }

      contentSize.height += component.headerHeight
      contentSize.height += component.footerHeight
      contentSize.width -= minimumInteritemSpacing
      contentSize.width += CGFloat(layout.inset.left + layout.inset.right)
    case .vertical:
      contentSize.width = component.view.frame.width
      contentSize.height = super.collectionViewContentSize.height
      contentSize.height += component.headerHeight
      contentSize.height += component.footerHeight
    }

    contentSize.height += CGFloat(layout.inset.top + layout.inset.bottom)
  }

  public override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
    var attributes = [NSCollectionViewLayoutAttributes]()

    guard let collectionView = collectionView,
      let dataSource = collectionView.dataSource as? DataSource,
      let component = dataSource.component,
      let layout = component.model.layout
      else {
        return attributes
    }

    guard let newAttributes = self.layoutAttributes else {
      return attributes
    }

    var nextX: CGFloat = sectionInset.left
    var nextY: CGFloat = 0.0

    for attribute in newAttributes {
      guard let itemAttribute = attribute.copy() as? NSCollectionViewLayoutAttributes else {
        continue
      }

      guard let indexPath = itemAttribute.indexPath else {
        continue
      }

      itemAttribute.size = component.sizeForItem(at: indexPath)

      if scrollDirection == .horizontal {
        if layout.itemsPerRow > 1 {
          if indexPath.item % Int(layout.itemsPerRow) == 0 {
            itemAttribute.frame.origin.y += sectionInset.top + component.headerHeight
          } else {
            itemAttribute.frame.origin.y = nextY
          }
        } else {
          itemAttribute.frame.origin.y = component.headerView?.frame.maxY ?? component.headerHeight
          itemAttribute.frame.origin.y += CGFloat(layout.inset.top)
        }

        itemAttribute.frame.origin.x = nextX

        if indexEligibleForItemsPerRow(index: indexPath.item, itemsPerRow: layout.itemsPerRow) {
          nextX += itemAttribute.size.width + minimumInteritemSpacing
          nextY = 0
        } else {
          nextY = itemAttribute.frame.maxY + CGFloat(layout.lineSpacing)
        }
      } else {
        itemAttribute.frame.origin.y += CGFloat(layout.inset.top)
      }

      attributes.append(itemAttribute)
    }

    return attributes
  }

  public override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
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

  public override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
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

  public override func prepare(forCollectionViewUpdates updateItems: [NSCollectionViewUpdateItem]) {
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
  fileprivate func applyAnimationFix(_ type: ComponentFlowLayout.AnimationType, _ attributes: NSCollectionViewLayoutAttributes) {
    // Add y offset to the first item in the row, otherwise it won't animate.
    if type == .insert && attributes.frame.origin.x == sectionInset.left {
      // To make it more accurate we can use a smaller offset for items that are not the
      // first item in the first row.
      let offset: CGFloat = attributes.indexPath!.item > 0 ? 0.1 : sectionInset.left
      attributes.frame.origin = .init(x: attributes.frame.origin.x, y: attributes.frame.origin.y - offset)
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
  private func applyAnimation(_ animation: Animation, type: AnimationType, to attributes: NSCollectionViewLayoutAttributes) {
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
      attributes.frame.origin.x = type == .insert ? collectionView.bounds.minX : collectionView.bounds.maxX
    case .left:
      attributes.frame.origin.x = type == .insert ? collectionView.bounds.maxX : collectionView.bounds.minX
    case .top:
      attributes.frame.origin.y += attributes.frame.size.height
      break
    case .bottom:
      if attributes.frame.origin.x == sectionInset.left {
        attributes.frame.origin = .init(x: attributes.frame.origin.x,
                                        y: attributes.frame.origin.y + attributes.frame.size.height)
      } else {
        attributes.frame.origin.y += attributes.frame.size.height
      }
      break
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
      attributes.alpha = 1.0
      attributes.frame.origin = .init(x: attributes.frame.origin.x,
                                      y: attributes.frame.origin.x - attributes.frame.size.height)
    }
  }

  public override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
    guard let collectionView = collectionView,
      let delegate = collectionView.delegate as? Delegate,
      let component = delegate.component else {
        return false
    }

    let offset: CGFloat = component.headerHeight + component.footerHeight
    let shouldInvalidateLayout = newBounds.size.height != collectionView.frame.height + offset

    return shouldInvalidateLayout
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
