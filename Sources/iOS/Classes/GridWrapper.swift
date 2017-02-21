import UIKit

class GridWrapper: UICollectionViewCell, Wrappable, Cell {

  weak var wrappedView: View?

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configureWrappedView() {
    if let cell = wrappedView as? UICollectionViewCell {
      cell.contentView.frame = contentView.frame
      cell.isUserInteractionEnabled = false
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    wrappedView?.frame.size = contentView.bounds.size
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
