import Cocoa

extension LayoutTrait {

  public func configure(spot: Gridable) {
    contentInset.configure(scrollView: spot.render())

    if let layout = spot.layout as? FlowLayout {
      sectionInset.configure(layout: layout)
      layout.minimumInteritemSpacing = CGFloat(itemSpacing)
      layout.minimumLineSpacing = CGFloat(lineSpacing)
    }
  }
}
