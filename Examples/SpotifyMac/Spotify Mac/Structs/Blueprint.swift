import Spots
import Sugar
import Malibu
import Brick

public struct Blueprint {

  public var cacheKey: String
  public var fragmentHandler: ((fragments: [String : AnyObject], controller: SpotsController) -> Void)? = nil
  public var requests: [(request: GETRequestable?, rootKey: String, spotIndex: Int, adapter: (json: JSONArray) -> [Item])]
  public var template: JSONDictionary

  init(cacheKey: String,
       requests: [(request: GETRequestable?, rootKey: String, spotIndex: Int, adapter: (json: JSONArray) -> [Item])] = [],
       fragmentHandler: ((fragments: [String : AnyObject], controller: SpotsController) -> Void)? = nil,
       template: JSONDictionary) {
    self.cacheKey = cacheKey
    self.fragmentHandler = fragmentHandler
    self.requests = requests
    self.template = template
  }
}

extension Blueprint {

  mutating func cacheKey(key: String) {
    cacheKey = key
  }
}
