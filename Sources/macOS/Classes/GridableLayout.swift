import Cocoa

public class GridableLayout: FlowLayout {

  public var contentSize = CGSize.zero

  private var layoutAttributes: [NSCollectionViewLayoutAttributes]?

  open override var collectionViewContentSize: CGSize {
    if scrollDirection != .horizontal {
      contentSize.height = super.collectionViewContentSize.height
    }

    return contentSize
  }

  open override func prepare() {
    guard let delegate = collectionView?.delegate as? Delegate,
      let component = delegate.component
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
      guard let firstItem = component.model.items.first else {
        return
      }

      contentSize.width = component.model.items.reduce(0, { $0 + floor($1.size.width) })
      contentSize.width += minimumInteritemSpacing * CGFloat(component.model.items.count)

      contentSize.height = firstItem.size.height
    case .vertical:
      contentSize.width = component.view.frame.width
      contentSize.height = super.collectionViewContentSize.height
    }

    if let componentLayout = component.model.layout {
      contentSize.height += CGFloat(componentLayout.inset.top + componentLayout.inset.bottom)
    }
  }

  public override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
    var attributes = [NSCollectionViewLayoutAttributes]()

    guard let collectionView = collectionView,
      let dataSource = collectionView.dataSource as? DataSource,
      let component = dataSource.component
      else {
        return attributes
    }

    guard let newAttributes = self.layoutAttributes else {
      return attributes
    }

    var offset: CGFloat = sectionInset.left

    for attribute in newAttributes {
      guard let itemAttribute = attribute.copy() as? NSCollectionViewLayoutAttributes
        else {
          continue
      }

      switch itemAttribute.representedElementCategory {
      case .item:
        guard let indexPath = itemAttribute.indexPath else {
          continue
        }

        itemAttribute.size = component.sizeForItem(at: indexPath)

        if scrollDirection == .horizontal {
          itemAttribute.frame.origin.y = headerReferenceSize.height + sectionInset.top
          itemAttribute.frame.origin.x = offset

          offset += itemAttribute.size.width + minimumInteritemSpacing
        }

        attributes.append(itemAttribute)
      default:
        break
      }
    }

    return attributes
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
}
