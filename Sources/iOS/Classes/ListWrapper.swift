import UIKit

class ListWrapper: UITableViewCell, Wrappable, Cell {

  weak var wrappedView: View?

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)

    backgroundColor = .clear
    selectedBackgroundView = UIView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

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
    super.setHighlighted(false, animated: false)
    (wrappedView as? ViewStateDelegate)?.viewStateDidChange(viewState)
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(false, animated: false)
    (wrappedView as? ViewStateDelegate)?.viewStateDidChange(viewState)
  }
}
