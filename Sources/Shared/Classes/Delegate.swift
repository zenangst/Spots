import Foundation

public class Delegate: NSObject {
  weak var spot: Spotable?

  init(spot: Spotable) {
    self.spot = spot
  }
}
