import UIKit

public class ListWrapper: UITableViewCell, Wrappable, Cell {

  weak public var wrappedView: View?

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)

    backgroundColor = .clear
    selectedBackgroundView = UIView()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configureWrappedView() {
    if let cell = wrappedView as? UITableViewCell {
      cell.contentView.frame = contentView.frame
      cell.isUserInteractionEnabled = false
    }
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    wrappedView?.frame.size = contentView.bounds.size
  }

  override public func prepareForReuse() {
    wrappedView?.removeFromSuperview()
  }

  // MARK: - View state

  override public func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated)
    (wrappedView as? ViewStateDelegate)?.viewStateDidChange(viewState)
  }

  override public func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    (wrappedView as? ViewStateDelegate)?.viewStateDidChange(viewState)
  }
}
