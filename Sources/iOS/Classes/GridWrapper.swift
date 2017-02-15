import UIKit

class GridWrapper: UICollectionViewCell, Wrappable {

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
}
