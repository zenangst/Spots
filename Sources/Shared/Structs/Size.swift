import Foundation
import CoreGraphics

// A struct for custom implementation of Codable protocols for CGSize
struct Size: Codable {
  private enum Key: String, CodingKey {
    case width
    case height
  }

  let width: CGFloat
  let height: CGFloat

  var cgSize: CGSize {
    return CGSize(width: width, height: height)
  }
}

// MARK: - Codable

extension Size {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Key.self)
    self.width = try container.decodeIfPresent(CGFloat.self, forKey: .width) ?? 0.0
    self.height = try container.decodeIfPresent(CGFloat.self, forKey: .height) ?? 0.0
  }
}

// MARK: - CGSize

extension Size {
  init(cgSize: CGSize) {
    self.width = cgSize.width
    self.height = cgSize.height
  }
}
