import UIKit

class GridWrapper: UICollectionViewCell, Wrappable, Cell {

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

  // MARK: - View state

  override var isSelected: Bool {
    didSet {
      (wrappedView as? ViewStateDelegate)?.viewStateDidChange(viewState)
    }
  }

  override var isHighlighted: Bool {
    didSet {
      (wrappedView as? ViewStateDelegate)?.viewStateDidChange(viewState)
    }
  }
}
