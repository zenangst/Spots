import Foundation

public class Delegate: NSObject {
  weak var spot: CoreComponent?

  init(spot: CoreComponent) {
    self.spot = spot
  }
}
