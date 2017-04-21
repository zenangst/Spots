import Foundation

public class DataSource: NSObject {
  weak var component: Component?
  var viewPreparer = ViewPreparer()

  init(component: Component) {
    self.component = component
  }
}
