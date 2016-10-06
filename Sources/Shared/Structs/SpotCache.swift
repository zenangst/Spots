import Foundation
import Cache
import CryptoSwift

/// A SpotCache struct used for Controller and Spotable object caching
public struct SpotCache {
  /// A unique identifer string for the SpotCache
  public let key: String
  /// The cache name used by Cache
  static let cacheName = String(describing: SpotCache.self)
  /// A JSON Cache object
  let cache = Cache<JSON>(name: "\(SpotCache.cacheName)/\(Bundle.main.bundleIdentifier!)")

  /// The path of the cache
  var path: String {
    return cache.path + "/" + fileName()
  }

  /// Checks if file exists for cache
  public var cacheExists: Bool {
    return FileManager.default.fileExists(atPath: path)
  }

  // MARK: - Initialization

  /// Initialize a SpotCache with a unique cache key
  ///
  /// - parameter key: A string that is used as an identifier for the SpotCache
  ///
  /// - returns: A SpotCache object
  public init(key: String) {
    self.key = key
  }

  // MARK: - Cache

  /// Save JSON to the SpotCache
  ///
  /// - parameter json: A JSON object
  public func save(_ json: [String : Any]) {
    let expiry = Expiry.date(Date().addingTimeInterval(60 * 60 * 24 * 3))
    SyncCache(cache).add(key, object: JSON.dictionary(json), expiry: expiry)
  }

  /// Load JSON from cache
  ///
  /// - returns: A Swift dictionary
  public func load() -> [String : Any] {
    return SyncCache(cache).object(key)?.object as? [String : Any] ?? [:]
  }

  /// Clear the current SpotCache
  public func clear() {
    cache.remove(key)
  }

  /// The SpotCache file name
  ///
  /// - returns: An md5 representation of the SpotCache's file name, computed from the SpotCache key
  func fileName() -> String {
    if let digest = key.data(using: String.Encoding.utf8)?.md5() {
      var string = ""
      for byte in digest {
        string += String(format:"%02x", byte)
      }

      return string
    }

    return ""
  }
}
