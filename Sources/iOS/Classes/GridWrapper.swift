import UIKit

class GridWrapper: UICollectionViewCell {

  weak var view: View?

  func configure(with view: View) {
    if let previousView = self.view {
      previousView.removeFromSuperview()
    }

    contentView.addSubview(view)
    self.view = view
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.view?.frame = contentView.bounds
  }

  override func prepareForReuse() {
    view?.removeFromSuperview()
  }
}
