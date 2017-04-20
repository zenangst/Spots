import Foundation

public class Delegate: NSObject {
  weak var component: Component?
  var viewPreparer = ViewPreparer()

  init(component: Component) {
    self.component = component
  }
}
