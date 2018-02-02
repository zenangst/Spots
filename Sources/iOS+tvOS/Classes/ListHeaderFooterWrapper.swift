import UIKit

class ListHeaderFooterWrapper: UITableViewHeaderFooterView, Wrappable {

  public var wrappedView: View?

  override func didMoveToSuperview() {
    super.didMoveToSuperview()

    backgroundView?.backgroundColor = .clear
  }
}
