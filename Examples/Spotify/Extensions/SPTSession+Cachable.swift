import Cache

extension SPTSession: Cachable {

  public typealias CacheType = SPTSession

  public static func decode(data: NSData) -> CacheType? {
    var object: SPTSession?
    do {
      object = try DefaultCacheConverter<SPTSession>().decode(data)
    } catch {}

    return object
  }

  public func encode() -> NSData? {
    var data: NSData?

    do {
      data = try DefaultCacheConverter<SPTSession>().encode(self)
    } catch {}

    return data
  }
}
