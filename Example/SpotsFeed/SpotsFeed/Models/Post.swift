import Foundation

public protocol PostConvertible {

  var wallModel: Post { get }
}

public class Post {

  public var id = 0
  public var publishDate = ""
  public var text = ""
  public var liked = false
  public var seen = false
  public var likeCount = 0
  public var seenCount = 0
  public var commentCount = 0
  public var author: Author?
  public var reusableIdentifier = PostTableViewCell.reusableIdentifier

  public var media: [Media]

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
