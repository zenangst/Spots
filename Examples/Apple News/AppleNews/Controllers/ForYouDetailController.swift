import Spots

class ForYouDetailController: SpotsController {

  override func viewDidLoad() {
    super.viewDidLoad()

    spot(0, Listable.self)?.tableView.separatorStyle = .None
  }

  func detailDidDismiss(sender: AnyObject) {
    navigationController?.dismissViewControllerAnimated(true, completion: nil)
  }
}
