import Cocoa

public class GridableLayout: FlowLayout {

  public var contentSize = CGSize.zero

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

    switch scrollDirection {
    case .horizontal:
      guard let firstItem = component.items.first else { return }

      contentSize.width = component.items.reduce(0, { $0 + floor($1.size.width) })
      contentSize.width += minimumInteritemSpacing * CGFloat(component.items.count - 1)

      contentSize.height = firstItem.size.height
    case .vertical:
      contentSize.width = component.view.frame.width
      contentSize.height = super.collectionViewContentSize.height
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
}
