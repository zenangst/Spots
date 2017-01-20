@testable import Spots
import Brick
#if os(OSX)
import Foundation
#else
import UIKit
#endif


extension Controller {

  func prepareController() {
    preloadView()
    viewDidAppear()
    spots.forEach {
      $0.view.layoutSubviews()
    }
  }

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

struct Helper {
  static func clearCache(for stateCache: StateCache?) {
    if FileManager().fileExists(atPath: stateCache!.path) {
      try! FileManager().removeItem(atPath: stateCache!.path)
    }
  }
}

#if !os(OSX)
  class CustomListCell: UITableViewCell, SpotConfigurable {

    var preferredViewSize: CGSize = CGSize(width: 0, height: 44)

    func configure(_ item: inout Item) {
      textLabel?.text = item.text
    }
  }

  class CustomListHeaderView: UITableViewHeaderFooterView, Componentable {
    var preferredHeaderHeight: CGFloat = 88

    func configure(_ component: Component) {
      textLabel?.text = component.title
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
