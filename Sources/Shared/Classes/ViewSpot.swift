#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif
import Brick

open class ViewSpot: NSObject, Spotable, Viewable {

  /// A Registry struct that contains all register components, used for resolving what UI component to use
  open static var views = Registry()
  open static var configure: ((_ view: View) -> Void)?
  open static var defaultView: View.Type = View.self
  open static var defaultKind: StringConvertible = "view"

  open weak var spotsCompositeDelegate: CompositeDelegate?
  open weak var spotsDelegate: SpotsDelegate?
  open var component: Component
  open var index = 0

  open var configure: ((SpotConfigurable) -> Void)?

  open lazy var scrollView: ScrollView = ScrollView()

  open fileprivate(set) var stateCache: SpotCache?

  open var adapter: SpotAdapter?

  /// Indicator to calculate the height based on content
  open var usesDynamicHeight = true

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

  open func render() -> View {
    return scrollView
  }

  /**
   Get the size of the item at the desired index path

   - parameter indexPath: An NSIndexPath

   - returns: The size of the item found using the index path
   */
  open func sizeForItem(at indexPath: IndexPath) -> CGSize {
    return scrollView.frame.size
  }

  /**
   A placeholder method, it is left empty as it holds no value for ViewSpot
   */
  open func deselect() {}

  // MARK: - Spotable

  /**
  A placeholder method, it is left empty as it holds no value for ViewSpot
   */
  open func register() {}
}
