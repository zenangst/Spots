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
      let spot = delegate.spot
      else {
        return
    }

    super.prepare()

    switch scrollDirection {
    case .horizontal:
      guard let firstItem = spot.items.first else { return }

      contentSize.width = spot.items.reduce(0, { $0 + floor($1.size.width) })
      contentSize.width += minimumInteritemSpacing * CGFloat(spot.items.count - 1)

      contentSize.height = firstItem.size.height
    case .vertical:
      contentSize.width = spot.view.frame.width
      contentSize.height = super.collectionViewContentSize.height
    }
  }

  public override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
    guard let collectionView = collectionView,
      let delegate = collectionView.delegate as? Delegate,
      let spot = delegate.spot else {
        return false
    }

    var offset: CGFloat = 0.0
    if let spot = spot as? Spot {
      offset += spot.headerHeight + spot.footerHeight
    }

    let shouldInvalidateLayout = newBounds.size.height != collectionView.frame.height + offset

    return shouldInvalidateLayout
  }
}
