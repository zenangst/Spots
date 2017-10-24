import Foundation
import Cache
import SwiftHash

/// A wrapper for Cache storage
private struct StateStorage {
  /// The cache name used by Cache
  static let cacheName = String(describing: StateStorage.self)

  /// Computed bundle identifier
  static let bundleIdentifer: String = {
    if let bundleIdentifier = Bundle.main.bundleIdentifier {
      return bundleIdentifier
    }
    return "Spots.bundle.identifier"
  }()

  static let stared = StateStorage()

  let storage: Storage?

  public func removeAll() {
    try? storage?.removeAll()
  }

  private init() {
    storage = try? Storage(
      diskConfig: DiskConfig(name: "\(StateStorage.cacheName)/\(StateStorage.bundleIdentifer)"),
      memoryConfig: MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
    )
  }
}

/// A StateCache struct used for Controller and Component object caching
public struct StateCache {

  /// A unique identifer string for the StateCache
  public let key: String

  /// A JSON Cache object
  let storage: Storage?

  /// Checks if file exists for cache
//  public var cacheExists: Bool {
//    return FileManager.default.fileExists(atPath: path)
//  }

  /// Remove state cache for all controllers and components.


  // MARK: - Initialization

  /// Initialize a StateCache with a unique cache key
  ///
  /// - parameter key: A string that is used as an identifier for the StateCache
  ///
  /// - returns: A StateCache object
  public init(key: String) {
    self.storage = StateStorage.stared.storage
    self.key = key
  }

  // MARK: - Cache

  /// Save JSON to the StateCache
  ///
  /// - parameter json: A JSON object
  public func save<T: Codable>(_ object: T) {
    let expiry = Expiry.date(Date().addingTimeInterval(60 * 60 * 24 * 3))
    try? storage?.setObject(object, forKey: key, expiry: expiry)
  }

  /// Load JSON from cache
  ///
  /// - returns: A Swift dictionary
  public func load<T: Codable>() -> T? {
    guard let object = try? storage?.object(ofType: T.self, forKey: key) else {
      return nil
    }
    return object
  }

  /// Clear the current StateCache
  public func clear(completion: (() -> Void)? = nil) {
    try? storage?.removeAll()
    completion?()
  }

  /// The StateCache file name
  ///
  /// - returns: An md5 representation of the StateCache's file name, computed from the StateCache key
  func fileName() -> String {
    return MD5(key)
  }
}
