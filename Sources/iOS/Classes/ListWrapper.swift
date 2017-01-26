import UIKit

class ListWrapper: UITableViewCell {

  weak var view: View?

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

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
