#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif
import Sugar
import Brick

public class ViewSpot: NSObject, Spotable, Viewable {

  public static var views = ViewRegistry()
  public static var configure: ((view: View) -> Void)?
  public static var defaultView: View.Type = View.self
  public static var defaultKind: StringConvertible = "view"

  public weak var spotsDelegate: SpotsDelegate?
  public var component: Component
  public var index = 0

  public var configure: (SpotConfigurable -> Void)?

  public lazy var scrollView: ScrollView = ScrollView()

  public private(set) var stateCache: SpotCache?

  public var adapter: SpotAdapter?

  public var responder: NSResponder {
    return scrollView
  }

  public var nextResponder: NSResponder? {
    get {
      return nil
    }
    set {}
  }

  public required init(component: Component) {
    self.component = component
    super.init()
    prepare()
  }

  public convenience init(title: String = "", kind: String? = nil) {
    self.init(component: Component(title: title, kind: kind ?? ViewSpot.defaultKind.string))
  }

  public func render() -> View {
    return scrollView
  }

  public func sizeForItemAt(indexPath: NSIndexPath) -> CGSize {
    return scrollView.frame.size
  }

  public func deselect() {}
}
