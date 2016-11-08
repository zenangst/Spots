import Foundation

public class DataSource: NSObject {
  weak var spot: Spotable?

  init(spot: Spotable) {
    self.spot = spot
  }
}
