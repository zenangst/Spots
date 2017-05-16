import Foundation

/// `DataSource` works as the data source for both table views and collection views.
/// It does this by implementing all of the necessary methods on either implementation
/// using protocol extensions (`DataSource+iOS+Extensions`, `DataSource+macOS+Extensions`). 
/// Each `Component` have their own `DataSource`, basically it supplies a default set of
/// implementations to use the `ComponentModel` as its source of truth. Mutating the data
/// source is handled by the `ComponentManager` also located on the `Component`.
public class DataSource: NSObject {
  /// The component that the data source belongs to.
  weak var component: Component?
  /// An object that ensures that all views displayed for this data source are properly
  /// configured with the model data. See `ItemConfigurable` for more information
  /// about how to configure your views.
  var viewPreparer = ViewPreparer()

  /// Initialize a new instance of a data source with a component.
  ///
  /// - Parameter component: The component that the data source belongs to.
  init(component: Component) {
    self.component = component
  }
}
