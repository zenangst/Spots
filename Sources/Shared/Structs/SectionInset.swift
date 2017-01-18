import Tailor
import Brick

public struct SectionInset: Mappable, DictionaryConvertible, Equatable {

  static let rootKey: String = "section-insets"

  var top: Double = 0.0
  var left: Double = 0.0
  var bottom: Double = 0.0
  var right: Double = 0.0

  public var dictionary: [String : Any] {
    return [
      GridableMeta.Key.sectionInsetTop: self.top,
      GridableMeta.Key.sectionInsetLeft: self.left,
      GridableMeta.Key.sectionInsetBottom: self.bottom,
      GridableMeta.Key.sectionInsetRight: self.right
    ]
  }

  public init(top: Double = 0.0, left: Double = 0.0, bottom: Double = 0.0, right: Double = 0.0) {
    self.top = top
    self.left = left
    self.bottom = bottom
    self.right = right
  }

  public init(_ map: [String : Any]) {
    self.top    <- map.property(GridableMeta.Key.sectionInsetTop)
    self.left   <- map.property(GridableMeta.Key.sectionInsetLeft)
    self.bottom <- map.property(GridableMeta.Key.sectionInsetBottom)
    self.right  <- map.property(GridableMeta.Key.sectionInsetRight)
  }

  public mutating func configure(withJSON JSON: [String : Any]) {
    self.top    <- JSON.property(GridableMeta.Key.sectionInsetTop)
    self.left   <- JSON.property(GridableMeta.Key.sectionInsetLeft)
    self.bottom <- JSON.property(GridableMeta.Key.sectionInsetBottom)
    self.right  <- JSON.property(GridableMeta.Key.sectionInsetRight)
  }

  public static func == (lhs: SectionInset, rhs: SectionInset) -> Bool {
    return lhs.top == rhs.top &&
      lhs.left == rhs.left &&
      lhs.bottom == rhs.bottom &&
      lhs.right == rhs.right
  }
}
