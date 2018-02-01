import Foundation
import CoreGraphics

/// `Delegate` works as the delegate for both table views and collection views.
/// It does this by implementing all of the necessary methods on either implementation
/// using protocol extensions (`Delegate+iOS+Extensions`, `Delegate+macOS+Extensions`).
/// Each `Component` has its own `Delegate`, its responsible for relying appropriate
/// invocations to `ComponentDelegate`, `ComponentFocusDelegate` etc.
/// `Delegate` is created in the init method for `Component`.
public class Delegate: NSObject, ComponentResolvable {
  /// The component that the delegate belongs to.
  weak var component: Component?
  /// An object that ensures that all views displayed for this data source are properly
  /// configured with the model data. See `ItemConfigurable` for more information
  /// about how to configure your views.
  let viewPreparer: ViewPreparer
  let configuration: Configuration
  let indexPathManager: IndexPathManager
  var needsInfiniteScrollingAlignment: Bool = false
  var beginDraggingAtContentOffset: CGPoint?

  #if os(tvOS)
  /// A boolean value that indicates that the scrolling offset has reached
  /// the added buffer when using infinite scrolling.
  var hasReachedBuffer: Bool = false
  /// A property used for navigating seamlessly with the focus engine on
  /// tvOS when a component has infinite scrolling enabled.
  var manualFocusedIndexPath: IndexPath = IndexPath(item: 0, section: 0)
  var initialFocusedIndexPath: IndexPath?
  #endif

  #if !os(macOS)
  /// The scroll view manager handles constraining horizontal components.
  /// They should not be vertically scrollable even if the content size exceeds the
  /// content size height. It also handles maintaining the position of headers and footers
  /// in components.
  var scrollViewManager = ScrollViewManager()
  #endif

  /// Initialize a new instance of a delegate with a component.
  ///
  /// - Parameter component: The component that the delegate belongs to.
  init(component: Component, with configuration: Configuration = .shared) {
    self.component = component
    self.configuration = configuration
    self.indexPathManager = IndexPathManager(component: component)
    self.viewPreparer = ViewPreparer(configuration: configuration)
  }
}
