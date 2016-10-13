import Foundation

open class Author {

  open var name: String
  open var avatar: URL?

  // MARK: - Initialization

  public init(name: String, avatar: URL? = nil) {
    self.name = name
    self.avatar = avatar
  }
}
