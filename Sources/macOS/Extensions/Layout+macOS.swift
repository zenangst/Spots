import Cocoa

extension Layout {

  public func configure(spot: Gridable) {
    inset.configure(scrollView: spot.view)

    if let layout = spot.layout as? FlowLayout {
      layout.minimumInteritemSpacing = CGFloat(itemSpacing)
      layout.minimumLineSpacing = CGFloat(lineSpacing)
    }
  }
}
