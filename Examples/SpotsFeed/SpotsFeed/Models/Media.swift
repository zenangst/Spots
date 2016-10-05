import Foundation

open class Media {

  public enum Kind {
    case image, video
  }

  open var kind: Kind
  open var source: URL?
  open var thumbnail: URL?

  // MARK: - Initialization

  public init(kind: Kind, source: URL?, thumbnail: URL? = nil) {
    self.kind = kind
    self.source = source

    if kind == .image {
      self.thumbnail = thumbnail ?? source
    }
  }
}
