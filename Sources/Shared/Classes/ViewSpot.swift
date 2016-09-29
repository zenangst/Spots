#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif
import Brick

public class ViewSpot: NSObject, Spotable, Viewable {

  /// A Registry struct that contains all register components, used for resolving what UI component to use
  public static var views = Registry()
  public static var configure: ((view: View) -> Void)?
  public static var defaultView: View.Type = View.self
  public static var defaultKind: StringConvertible = "view"

  public weak var spotsCompositeDelegate: SpotsCompositeDelegate?
  public weak var spotsDelegate: SpotsDelegate?
  public var component: Component
  public var index = 0

  public var configure: (SpotConfigurable -> Void)?

  public lazy var scrollView: ScrollView = ScrollView()

  public private(set) var stateCache: SpotCache?

  public var adapter: SpotAdapter?

  /// Indicator to calculate the height based on content
  public var usesDynamicHeight = true

  public required init(component: Component) {
    self.component = component
    super.init()
    registerDefault(view: View.self)
    prepare()
  }

  /**
   A convenience initializer for creating a new ViewSpot with title and kind

   - parameter title: A string that will be set as the title for the Component
   - parameter kind:  The kind that will be used on the Component
   */
  public convenience init(title: String = "", kind: String? = nil) {
    self.init(component: Component(title: title, kind: kind ?? ViewSpot.defaultKind.string))
  }

  public func render() -> View {
    return scrollView
  }

  /**
   Get the size of the item at the desired index path

   - parameter indexPath: An NSIndexPath

   - returns: The size of the item found using the index path
   */
  public func sizeForItemAt(indexPath: NSIndexPath) -> CGSize {
    return scrollView.frame.size
  }

  /**
   A placeholder method, it is left empty as it holds no value for ViewSpot
   */
  public func deselect() {}

  // MARK: - Spotable

  /**
  A placeholder method, it is left empty as it holds no value for ViewSpot
   */
  public func register() {}
}
