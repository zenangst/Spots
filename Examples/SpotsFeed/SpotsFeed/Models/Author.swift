import Foundation

public class Author {

  public var name: String
  public var avatar: NSURL?

  // MARK: - Initialization

  public init(name: String, avatar: NSURL? = nil) {
    self.name = name
    self.avatar = avatar
  }
}
