import Foundation
import Sugar
import Cache
import CryptoSwift

/// A SpotCache struct used for SpotsController and Spotable object caching
public struct SpotCache {

  public let key: String
  static let cacheName = "SpotCache"
  let cache = Cache<JSON>(name: "\(SpotCache.cacheName)/\(NSBundle.mainBundle().bundleIdentifier!)")

  var path: String {
    return cache.path + "/" + fileName()
  }

  public var cacheExists: Bool {
    return NSFileManager.defaultManager().fileExistsAtPath(path)
  }

  // MARK: - Initialization

  public init(key: String) {
    self.key = key
  }

  // MARK: - Cache

  public func save(json: [String : AnyObject]) {
    let expiry = Expiry.Date(NSDate().dateByAddingTimeInterval(60 * 60 * 24 * 3))
    SyncCache(cache).add(key, object: JSON.Dictionary(json), expiry: expiry)
  }

  public func load() -> [String : AnyObject] {
    return SyncCache(cache).object(key)?.object as? [String : AnyObject] ?? [:]
  }

  public func clear() {
    cache.remove(key)
  }

  func fileName() -> String {
    if let digest = key.dataUsingEncoding(NSUTF8StringEncoding)?.md5() {
      var string = ""
      var byte: UInt8 = 0

      for i in 0 ..< digest.length {
        digest.getBytes(&byte, range: NSRange(location: i, length: 1))
        string += String(format: "%02x", byte)
      }

      return string
    }

    return ""
  }
}
