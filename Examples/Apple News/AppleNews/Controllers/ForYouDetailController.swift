import Spots

class ForYouDetailController: SpotsController {

  func detailDidDismiss(sender: AnyObject) {
    navigationController?.dismissViewControllerAnimated(true, completion: nil)
  }
}
