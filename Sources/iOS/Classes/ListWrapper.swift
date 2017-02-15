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

  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated)
    (wrappedView as? ViewStateDelegate)?.viewStateDidChange(viewState)
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    (wrappedView as? ViewStateDelegate)?.viewStateDidChange(viewState)
  }
}
