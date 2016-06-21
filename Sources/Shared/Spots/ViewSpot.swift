import Foundation
import Sugar
import Brick

public class ViewSpot: NSObject, Spotable, Viewable {

  public static var views = ViewRegistry()
  public static var configure: ((view: RegularView) -> Void)?
  public static var defaultView: RegularView.Type = RegularView.self
  public static var defaultKind: StringConvertible = "view"

  public weak var spotsDelegate: SpotsDelegate?
  public var component: Component
  public var index = 0

  public var configure: (SpotConfigurable -> Void)?

  public lazy var scrollView: ScrollView = ScrollView()

  public private(set) var stateCache: SpotCache?

  public required init(component: Component) {
    self.component = component
    super.init()
    prepare()
  }

  public convenience init(title: String = "", kind: String? = nil) {
    self.init(component: Component(title: title, kind: kind ?? ViewSpot.defaultKind.string))
  }

  public func render() -> RegularView {
    return scrollView
  }
}
