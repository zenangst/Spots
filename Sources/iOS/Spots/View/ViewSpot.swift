import UIKit
import Sugar

public class ViewSpot: NSObject, Spotable, Viewable {

  public static var views = ViewRegistry()
  public static var configure: ((view: UICollectionView) -> Void)?
  public static var defaultView: UIView.Type = UIView.self
  public static var defaultKind = "view"

  public weak var spotsDelegate: SpotsDelegate?
  public var component: Component
  public var index = 0

  public var configure: (SpotConfigurable -> Void)?

  public lazy var scrollView = UIScrollView()

  public required init(component: Component) {
    self.component = component
    super.init()
    prepare()
  }

  public convenience init(title: String = "", kind: String? = nil) {
    self.init(component: Component(title: title, kind: kind ?? ViewSpot.defaultKind))
  }
}
