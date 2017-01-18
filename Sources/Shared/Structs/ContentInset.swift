import Tailor
import Brick

struct ContentInset: Mappable, DictionaryConvertible {

  static let rootKey: String = "content-insets"

  var top: Double = 0.0
  var left: Double = 0.0
  var bottom: Double = 0.0
  var right: Double = 0.0

  public var dictionary: [String : Any] {
    return [
      GridableMeta.Key.contentInsetTop    : self.top,
      GridableMeta.Key.contentInsetLeft   : self.left,
      GridableMeta.Key.contentInsetBottom : self.bottom,
      GridableMeta.Key.contentInsetRight  : self.right
    ]
  }

  public init(top: Double = 0.0, left: Double = 0.0, bottom: Double = 0.0, right: Double = 0.0) {
    self.top = top
    self.left = left
    self.bottom = bottom
    self.right = right
  }

  public init(_ map: [String : Any]) {
    self.top    <- map.property(GridableMeta.Key.contentInsetTop)
    self.left   <- map.property(GridableMeta.Key.contentInsetLeft)
    self.bottom <- map.property(GridableMeta.Key.contentInsetBottom)
    self.right  <- map.property(GridableMeta.Key.contentInsetRight)
  }

  public mutating func configure(withJSON JSON: [String : Any]) {
    self.top    <- JSON.property(GridableMeta.Key.contentInsetTop)
    self.left   <- JSON.property(GridableMeta.Key.contentInsetLeft)
    self.bottom <- JSON.property(GridableMeta.Key.contentInsetBottom)
    self.right  <- JSON.property(GridableMeta.Key.contentInsetRight)
  }
}
