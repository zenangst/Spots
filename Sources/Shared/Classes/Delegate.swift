import Foundation

/// `Delegate` works as the delegate for both table views and collection views.
/// It does this by implementing all of the necessary methods on either implementation
/// using protocol extensions (`Delegate+iOS+Extensions`, `Delegate+macOS+Extensions`).
/// Each `Component` has its own `Delegate`, its responsible for relying appropriate
/// invocations to `ComponentDelegate`, `ComponentFocusDelegate` etc.
/// `Delegate` is created in the init method for `Component`.
public class Delegate: NSObject {
  /// The component that the delegate belongs to.
  weak var component: Component?
  /// An object that ensures that all views displayed for this data source are properly
  /// configured with the model data. See `ItemConfigurable` for more information
  /// about how to configure your views.
  var viewPreparer = ViewPreparer()

  /// Initialize a new instance of a delegate with a component.
  ///
  /// - Parameter component: The component that the delegate belongs to.
  init(component: Component) {
    self.component = component
  }
}
