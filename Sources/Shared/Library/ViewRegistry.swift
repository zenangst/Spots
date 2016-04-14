import UIKit
import Brick

public struct ViewRegistry {
  var storage = [String : UIView.Type]()
  
  public subscript(key: StringConvertible) -> UIView.Type? {
    get {
      return storage[key.string]
    }
    set(value) {
      storage[key.string] = value
    }
  }
}