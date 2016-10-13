import Cache

extension SPTSession: Cachable {

  public typealias CacheType = SPTSession

  public static func decode(_ data: Data) -> CacheType? {
    return NSKeyedUnarchiver.unarchiveObject(with: data) as? SPTSession
  }

  public func encode() -> Data? {
    return NSKeyedArchiver.archivedData(withRootObject: self)
  }
}
