import Spots
import Sugar

class ForYouDetailController: SpotsController {

  var lastContentOffset: CGPoint?

  lazy var barView: UIVisualEffectView = {
    let effect = UIBlurEffect(style: .ExtraLight)
    let view = UIVisualEffectView(effect: effect)
    view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 20)
    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(barView)

    spot(0, Listable.self)?.tableView.separatorStyle = .None
  }

  func detailDidDismiss(sender: AnyObject) {
    navigationController?.dismissViewControllerAnimated(true, completion: nil)
  }
}

extension ForYouDetailController {

  override func scrollViewDidScroll(scrollView: UIScrollView) {
    super.scrollViewDidScroll(scrollView)

    guard let navigationController = navigationController
      where scrollView.tracking
      else { return }

    if spotsScrollView.contentOffset.y >= lastContentOffset?.y && spotsScrollView.contentOffset.y > 64 {
      navigationController.setNavigationBarHidden(true, animated: true)
    } else {
      navigationController.setNavigationBarHidden(false, animated: true)
    }

    lastContentOffset = spotsScrollView.contentOffset
  }

}
