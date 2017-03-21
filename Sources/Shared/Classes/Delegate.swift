import Foundation

public class Delegate: NSObject {
  weak var component: Component?

  init(component: Component) {
    self.component = component
  }
}
