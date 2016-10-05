import Spots
import Sugar
import Malibu
import Brick

public struct Blueprint {

  public var cacheKey: String
  public var fragmentHandler: ((_ fragments: [String : Any], _ controller: SpotsController) -> Void)? = nil
  public var requests: [(request: GETRequestable?, rootKey: String, spotIndex: Int, adapter: (_ json: [[String : Any]]) -> [Item])]
  public var template: [String : Any]

  init(cacheKey: String,
       requests: [(request: GETRequestable?, rootKey: String, spotIndex: Int, adapter: (_ json: [[String : Any]]) -> [Item])] = [],
       fragmentHandler: ((_ fragments: [String : Any], _ controller: SpotsController) -> Void)? = nil,
       template: [String : Any]) {
    self.cacheKey = cacheKey
    self.fragmentHandler = fragmentHandler
    self.requests = requests
    self.template = template
  }
}

extension Blueprint {

  mutating func cacheKey(_ key: String) {
    cacheKey = key
  }
}
