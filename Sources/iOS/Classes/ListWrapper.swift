import UIKit

class ListWrapper: UITableViewCell, Wrappable, Cell {

  weak var wrappedView: View?

  func configureWrappedView() {
    if let cell = wrappedView as? UITableViewCell {
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
