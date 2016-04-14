import UIKit
import Brick

public struct ViewRegistry {
  var views = [String : UIView.Type]()
  
  public subscript(key: StringConvertible) -> UIView.Type? {
    get {
      return views[key.string]
    }
    set {
      views[key.string] = newValue
    }
  }
}