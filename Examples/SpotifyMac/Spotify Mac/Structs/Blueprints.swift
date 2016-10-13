import Spots
import Sugar
import Malibu
import Brick

public struct Blueprints {

  var storage = [String : Blueprint]()

  public subscript(key: StringConvertible) -> Blueprint? {
    get {
      return storage[key.string]
    }
    set(value) {
      storage[key.string] = value
    }
  }

  mutating func register(_ containerType: BlueprintContainer.Type) {
    self.storage[containerType.key] = containerType.drawing
  }
}
