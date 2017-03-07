import Foundation

public class Delegate: NSObject {
  weak var component: CoreComponent?

  init(component: CoreComponent) {
    self.component = component
  }
}
