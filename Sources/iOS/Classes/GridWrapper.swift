import UIKit

class GridWrapper: UICollectionViewCell, Wrappable {

  weak var wrappedView: View?

  override func layoutSubviews() {
    super.layoutSubviews()

    self.wrappedView?.frame = contentView.bounds
  }

  override func prepareForReuse() {
    wrappedView?.removeFromSuperview()
  }
}
