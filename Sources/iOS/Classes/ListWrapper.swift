import UIKit

class ListWrapper: UITableViewCell, Wrappable {

  weak var wrappedView: View?

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)

    backgroundColor = .clear
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
}
