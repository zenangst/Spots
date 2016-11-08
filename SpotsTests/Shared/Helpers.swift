import Spots
import Brick
#if os(OSX)
import Foundation
#else
import UIKit
#endif


extension Controller {

  func preloadView() {
    let _ = view
    #if os(OSX)
      view.frame.size = CGSize(width: 100, height: 100)
    #endif
  }
  #if !os(OSX)
  func viewDidAppear() {
    viewWillAppear(true)
    viewDidAppear(true)
  }
  #endif

  func scrollTo(_ point: CGPoint) {
    #if !os(OSX)
    scrollView.setContentOffset(point, animated: false)
    scrollView.layoutSubviews()
    #endif
  }
}

#if !os(OSX)
class CustomListCell: UITableViewCell, SpotConfigurable {

  var preferredViewSize: CGSize = CGSize(width: 0, height: 44)

  func configure(_ item: inout Item) {
    textLabel?.text = item.text
  }
}

class CustomGridCell: UICollectionViewCell, SpotConfigurable {

  var preferredViewSize: CGSize = CGSize(width: 0, height: 44)

  func configure(_ item: inout Item) {}
}

class CustomGridHeaderView: UICollectionReusableView, Componentable {

  var preferredHeaderHeight: CGFloat = 88

  lazy var textLabel = UILabel()

  func configure(_ component: Component) {
    textLabel.text = component.title
  }
}
#endif
