import Cache

extension SPTSession: Cachable {

  public typealias CacheType = SPTSession

  public static func decode(data: NSData) -> CacheType? {
    return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? SPTSession
  }

  public func encode() -> NSData? {
    return NSKeyedArchiver.archivedDataWithRootObject(self)
  }
}
