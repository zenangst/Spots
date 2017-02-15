import UIKit

class GridWrapper: UICollectionViewCell, Wrappable {

  weak var wrappedView: View?

  override func layoutSubviews() {
    super.layoutSubviews()

    wrappedView?.frame.size = contentView.bounds.size
  }

  func configureWrappedView() {
    if let cell = wrappedView as? UICollectionViewCell {
      cell.contentView.frame = contentView.frame
      cell.isUserInteractionEnabled = false
    }
  }

  override func prepareForReuse() {
    wrappedView?.removeFromSuperview()
  }
}
