import Foundation

public protocol PostConvertible {

  var wallModel: Post { get }
}

open class Post {

  open var id = 0
  open var publishDate = ""
  open var text = ""
  open var liked = false
  open var seen = false
  open var likeCount = 0
  open var seenCount = 0
  open var commentCount = 0
  open var author: Author?
  open var reusableIdentifier = PostTableViewCell.reusableIdentifier

  open var media: [Media]

  // MARK: - Initialization

  public init(id: Int, text: String = "", publishDate: String, author: Author? = nil,
    media: [Media] = [], reusableIdentifier: String? = nil) {
      self.id = id
      self.text = text
      self.publishDate = publishDate
      self.author = author
      self.media = media

      if let reusableIdentifier = reusableIdentifier {
        self.reusableIdentifier = reusableIdentifier
      }
  }
}

// MARK: - PostConvertible

extension Post: PostConvertible {

  public var wallModel: Post {
    return self
  }
}
