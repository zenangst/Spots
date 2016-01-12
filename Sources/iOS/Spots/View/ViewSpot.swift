import UIKit
import Sugar

public class ViewSpot: NSObject, Spotable, Viewable {

  public static var views = [String: UIView.Type]()
  public static var configure: ((view: UICollectionView) -> Void)?
  public static var defaultView: UIView.Type = UIView.self

  public weak var spotsDelegate: SpotsDelegate?
  public var component: Component
  public var index = 0

  public lazy var scrollView = UIScrollView()

  public required init(component: Component) {
    self.component = component
    super.init()
  public convenience init(title: String = "", kind: String = "view") {
    self.init(component: Component(title: title, kind: kind))
  }
}
