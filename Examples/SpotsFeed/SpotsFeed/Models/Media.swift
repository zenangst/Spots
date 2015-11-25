import Foundation

public class Media {

  public enum Kind {
    case Image, Video
  }

  public var kind: Kind
  public var source: NSURL?
  public var thumbnail: NSURL?

  // MARK: - Initialization

  public init(kind: Kind, source: NSURL?, thumbnail: NSURL? = nil) {
    self.kind = kind
    self.source = source

    if kind == .Image {
      self.thumbnail = thumbnail ?? source
    }
  }
}
