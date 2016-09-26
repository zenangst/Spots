import Foundation
import Cache
import CryptoSwift

/// A SpotCache struct used for SpotsController and Spotable object caching
public struct SpotCache {

  public let key: String
  static let cacheName = "SpotCache"
  let cache = Cache<JSON>(name: "\(SpotCache.cacheName)/\(NSBundle.mainBundle().bundleIdentifier!)")

  /// The path of the cache
  var path: String {
    return cache.path + "/" + fileName()
  }

  /// Checks if file exists for cache
  public var cacheExists: Bool {
    return NSFileManager.defaultManager().fileExistsAtPath(path)
  }

  // MARK: - Initialization

  /**
   Initialize a SpotCache with a unique cache key

   - parameter key: A string that is used as an identifier for the SpotCache
   */
  public init(key: String) {
    self.key = key
  }

  // MARK: - Cache

  /**
   Save JSON to the SpotCache

   - parameter json: A JSON object
   */
  public func save(json: [String : AnyObject]) {
    let expiry = Expiry.Date(NSDate().dateByAddingTimeInterval(60 * 60 * 24 * 3))
    SyncCache(cache).add(key, object: JSON.Dictionary(json), expiry: expiry)
  }

  /**
   Load JSON from cache

   - returns: A Swift dictionary
   */
  public func load() -> [String : AnyObject] {
    return SyncCache(cache).object(key)?.object as? [String : AnyObject] ?? [:]
  }

  /**
   Clear the current SpotCache
   */
  public func clear() {
    cache.remove(key)
  }

  /**
   The SpotCache file name

   - returns: An md5 representation of the SpotCache's file name, computed from the SpotCache key
   */
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
