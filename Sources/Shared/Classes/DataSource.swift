import Foundation

public class DataSource: NSObject {
  weak var component: Component?

  init(component: Component) {
    self.component = component
  }
}
