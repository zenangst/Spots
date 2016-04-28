import Foundation
import Sugar
import Cache

public struct SpotCache {

  public let key: String
  let cache = Cache<JSON>(name: "SpotCache")

  // MARK: - Initialization

  public init(key: String) {
    self.key = key
  }

  // MARK: - Cache

  func save(json: JSONDictionary) {
    let expiry = Expiry.Date(NSDate().dateByAddingTimeInterval(60 * 60 * 24 * 3))
    SyncCache(cache).add(key, object: JSON.Dictionary(json), expiry: expiry)
  }

  func load() -> JSONDictionary {
    return SyncCache(cache).object(key)?.object as? JSONDictionary ?? [:]
  }

  func clear() {
    cache.remove(key)
  }
}
