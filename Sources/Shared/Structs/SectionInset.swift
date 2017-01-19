import Tailor
import Brick

public struct SectionInset: Mappable, Equatable {

  static let rootKey: String = "section-inset"

  enum Key: String {
    case top, left, bottom, right
  }

  var top: Double = 0.0
  var left: Double = 0.0
  var bottom: Double = 0.0
  var right: Double = 0.0

  public var dictionary: [String : Double] {
    return [
      Key.top.rawValue: self.top,
      Key.left.rawValue: self.left,
      Key.bottom.rawValue: self.bottom,
      Key.right.rawValue: self.right
    ]
  }

  public init(top: Double = 0.0, left: Double = 0.0, bottom: Double = 0.0, right: Double = 0.0) {
    self.top = top
    self.left = left
    self.bottom = bottom
    self.right = right
  }

  public init(_ block: (inout SectionInset) -> Void) {
    self.init([:])
    block(&self)
  }

  public init(_ map: [String : Any]) {
    self.top    <- map.property(Key.top.rawValue)
    self.left   <- map.property(Key.left.rawValue)
    self.bottom <- map.property(Key.bottom.rawValue)
    self.right  <- map.property(Key.right.rawValue)
  }

  public mutating func configure(withJSON JSON: [String : Any]) {
    self.top    <- JSON.property(Key.top.rawValue)
    self.left   <- JSON.property(Key.left.rawValue)
    self.bottom <- JSON.property(Key.bottom.rawValue)
    self.right  <- JSON.property(Key.right.rawValue)
  }

  public static func == (lhs: SectionInset, rhs: SectionInset) -> Bool {
    return lhs.top == rhs.top &&
      lhs.left == rhs.left &&
      lhs.bottom == rhs.bottom &&
      lhs.right == rhs.right
  }
}
