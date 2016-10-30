import Foundation
import Cache
import CryptoSwift

/// A StateCache struct used for Controller and Spotable object caching
public struct StateCache {

  /// A unique identifer string for the StateCache
  public let key: String

  /// The cache name used by Cache
  static let cacheName = String(describing: StateCache.self)

  /// Computed bundle identifier
  static let bundleIdentifer: String = {
    if let bundleIdentifier = Bundle.main.bundleIdentifier {
      return bundleIdentifier
    }
    return "Spots.bundle.identifier"
  }()

  /// A JSON Cache object
  let cache = Cache<JSON>(name: "\(StateCache.cacheName)/\(bundleIdentifer)")

  /// The path of the cache
  var path: String {
    return cache.path + "/" + fileName()
  }

  /// Checks if file exists for cache
  public var cacheExists: Bool {
    return FileManager.default.fileExists(atPath: path)
  }

  // MARK: - Initialization

  /// Initialize a StateCache with a unique cache key
  ///
  /// - parameter key: A string that is used as an identifier for the StateCache
  ///
  /// - returns: A StateCache object
  public init(key: String) {
    self.key = key
  }

  // MARK: - Cache

  /// Save JSON to the StateCache
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

  /// Clear the current StateCache
  public func clear(completion: (() -> Void)? = nil) {
    cache.remove(key) {
      completion?()
    }
  }

  /// The StateCache file name
  ///
  /// - returns: An md5 representation of the StateCache's file name, computed from the StateCache key
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
