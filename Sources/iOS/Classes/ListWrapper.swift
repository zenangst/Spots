import UIKit

class ListWrapper: UITableViewCell, Wrappable {

  weak var wrappedView: View?

  func configureWrappedView() {
    if let cell = wrappedView as? UITableViewCell {
      cell.contentView.frame = contentView.frame
      cell.isUserInteractionEnabled = false
    }
  }
  override func layoutSubviews() {
    super.layoutSubviews()

    self.wrappedView?.frame = contentView.bounds
  }

  override func prepareForReuse() {
    wrappedView?.removeFromSuperview()
  }
}
