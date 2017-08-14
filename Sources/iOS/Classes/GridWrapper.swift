import UIKit

public class GridWrapper: UICollectionViewCell, Wrappable, Cell {

  weak public var wrappedView: View?

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    wrappedView?.frame.size = contentView.bounds.size
  }

  override public func prepareForReuse() {
    wrappedView?.removeFromSuperview()
  }

  // MARK: - View state

  override public var isSelected: Bool {
    didSet {
      (wrappedView as? ViewStateDelegate)?.viewStateDidChange(viewState)
    }
  }

  override public var isHighlighted: Bool {
    didSet {
      (wrappedView as? ViewStateDelegate)?.viewStateDidChange(viewState)
    }
  }
}
