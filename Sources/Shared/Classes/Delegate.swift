import Foundation

public class Delegate: NSObject {

  var component: Component
  weak var spot: Spotable!

  init(component: Component) {
    self.component = component
  }
}
