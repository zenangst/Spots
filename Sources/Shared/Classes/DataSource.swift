import Foundation

public class DataSource: NSObject {
  weak var component: CoreComponent?

  init(component: CoreComponent) {
    self.component = component
  }
}
