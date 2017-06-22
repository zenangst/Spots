import Foundation
import Cache
import SwiftHash

/// A StateCache struct used for Controller and Component object caching
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
  let cache = SpecializedCache<JSON>(name: "\(StateCache.cacheName)/\(bundleIdentifer)")

  /// The path of the cache
  var path: String {
    return cache.path + "/" + fileName()
  }

  /// Checks if file exists for cache
  public var cacheExists: Bool {
    return FileManager.default.fileExists(atPath: path)
  }

  /// Remove state cache for all controllers and components.
  public static func removeAll() {
    let path = SpecializedCache<JSON>(name: "\(StateCache.cacheName)/\(bundleIdentifer)").path
    do {
      try FileManager.default.removeItem(atPath: path)
    } catch {
      NSLog("🎍 SPOTS: Unable to remove cache.")
    }
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
    try? cache.addObject(JSON.dictionary(json), forKey: key, expiry: expiry)
  }

  /// Load JSON from cache
  ///
  /// - returns: A Swift dictionary
  public func load() -> [String : Any] {
    guard let cachedDictionary = cache.object(forKey: key)?.object as? [String: Any] else {
      return [:]
    }

    return cachedDictionary
  }

  /// Clear the current StateCache
  public func clear(completion: (() -> Void)? = nil) {
    try? cache.clear(keepingRootDirectory: true)
    completion?()
  }

  /// The StateCache file name
  ///
  /// - returns: An md5 representation of the StateCache's file name, computed from the StateCache key
  func fileName() -> String {
    return MD5(key)
  }
}
