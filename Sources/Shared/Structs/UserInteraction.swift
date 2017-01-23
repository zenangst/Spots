import Foundation
import Tailor

public struct UserInteraction: Mappable {

  enum Key: String {
    case paginate = "paginate"
  }

  var paginate: Paginate = .disabled

  static let rootKey: String = "user-interaction"

  public var dictionary: [String : Any] {
    return [
      Key.paginate.rawValue: paginate.rawValue
    ]
  }

  public init(_ map: [String : Any] = [:]) {
    configure(withJSON: map)
  }

  public mutating func configure(withJSON map: [String : Any]) {
    if Component.legacyMapping {
      if let _: Bool = map.property(Key.paginate.rawValue) {
        self.paginate = .byPage
      }
    } else if let paginate: String = map.property(Key.paginate.rawValue) {
      self.paginate <- Paginate(rawValue: paginate)
    }

  }

  public static func == (lhs: UserInteraction, rhs: UserInteraction) -> Bool {
    return lhs.paginate == rhs.paginate
  }

  public static func != (lhs: UserInteraction, rhs: UserInteraction) -> Bool {
    return !(lhs == rhs)
  }
}
