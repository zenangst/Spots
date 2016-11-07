import Foundation

public class DataSource: NSObject {

  var component: Component
  weak var spot: Spotable!

  init(component: Component) {
    self.component = component
  }
}
