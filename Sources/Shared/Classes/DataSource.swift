import Foundation

public class DataSource: NSObject {
  weak var spot: CoreComponent?

  init(spot: CoreComponent) {
    self.spot = spot
  }
}
