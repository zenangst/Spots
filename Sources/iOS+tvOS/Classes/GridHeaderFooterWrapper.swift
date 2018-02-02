import UIKit

class GridHeaderFooterWrapper: UICollectionReusableView, Wrappable {

  public var wrappedView: View?

  public var contentView: View {
    return self
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.wrappedView?.frame = contentView.bounds
  }

  override func prepareForReuse() {
    wrappedView?.removeFromSuperview()
  }
}
