import Cocoa

extension Layout {

  public func configure(spot: Gridable) {
    inset.configure(scrollView: spot.view)

    if let layout = spot.layout as? FlowLayout {
      layout.minimumInteritemSpacing = CGFloat(itemSpacing)
      layout.minimumLineSpacing = CGFloat(lineSpacing)
    }
  }

  public func configure(collectionViewLayout: FlowLayout) {
    collectionViewLayout.sectionInset = EdgeInsets(
      top: CGFloat(inset.top),
      left: CGFloat(inset.left),
      bottom: CGFloat(inset.bottom),
      right: CGFloat(inset.right)
    )

    collectionViewLayout.minimumInteritemSpacing = CGFloat(itemSpacing)
    collectionViewLayout.minimumLineSpacing = CGFloat(lineSpacing)
  }
}
