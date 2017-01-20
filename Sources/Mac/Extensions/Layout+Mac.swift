import Cocoa

extension Layout {

  public func configure(spot: Gridable) {
    inset.configure(scrollView: spot.render())

    if let layout = spot.layout as? FlowLayout {
      inset.configure(layout: layout)
      layout.minimumInteritemSpacing = CGFloat(itemSpacing)
      layout.minimumLineSpacing = CGFloat(lineSpacing)
    }
  }
}
