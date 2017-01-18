#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif
import Brick

open class ViewSpot: NSObject, Spotable, Viewable {

  public static var layoutTrait: LayoutTrait = LayoutTrait([:])

  /// Reload spot with ItemChanges.
  ///
  /// - parameter changes:          A collection of changes: inserations, updates, reloads, deletions and updated children.
  /// - parameter animation:        A Animation that is used when performing the mutation.
  /// - parameter updateDataSource: A closure to update your data source.
  /// - parameter completion:       A completion closure that runs when your updates are done.
  public func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: Animation, updateDataSource: () -> Void, completion: Completion) {
    completion?()
  }

  /// A Registry struct that contains all register components, used for resolving what UI component to use
  open static var headers = Registry()
  open static var views = Registry()
  open static var configure: ((_ view: View) -> Void)?
  open static var defaultView: View.Type = View.self
  open static var defaultKind: StringConvertible = "view"

  open weak var delegate: SpotsDelegate?
  open var component: Component
  open var index = 0
  open var configure: ((SpotConfigurable) -> Void)?

  /// A SpotsFocusDelegate object
  weak public var focusDelegate: SpotsFocusDelegate?

  /// Child spots
  public var compositeSpots: [CompositeSpot] = []

  open lazy var scrollView: ScrollView = ScrollView()

  open fileprivate(set) var stateCache: StateCache?

  /// Indicator to calculate the height based on content
  open var usesDynamicHeight = true

  public var userInterface: UserInterface?

  public required init(component: Component) {
    self.component = component

    if self.component.layoutTrait == nil {
      self.component.layoutTrait = type(of: self).layoutTrait
    }

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

  public func ui<T>(at index: Int) -> T? {
    return nil
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
