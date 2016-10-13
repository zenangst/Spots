import Spots
import Sugar

class ForYouDetailController: Controller {

  var lastContentOffset: CGPoint?

  lazy var barView: UIVisualEffectView = {
    let effect = UIBlurEffect(style: .extraLight)
    let view = UIVisualEffectView(effect: effect)
    view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 20)
    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(barView)

    spot(at: 0, ofType: Listable.self)?.tableView.separatorStyle = .none
  }

  func detailDidDismiss(_ sender: AnyObject) {
    navigationController?.dismiss(animated: true, completion: nil)
  }
}

extension ForYouDetailController {

  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    super.scrollViewDidScroll(scrollView)

    guard let navigationController = navigationController, scrollView.isTracking
      else { return }

    if scrollView.contentOffset.y >= (lastContentOffset?.y)! && scrollView.contentOffset.y > 64 {
      navigationController.setNavigationBarHidden(true, animated: true)
    } else {
      navigationController.setNavigationBarHidden(false, animated: true)
    }

    lastContentOffset = scrollView.contentOffset
  }

}
