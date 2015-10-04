import Tailor
import Sugar

struct Component: Mappable {
  var title = ""
  var type = ""
  var items = [ListItem]()

  init(_ map: JSONDictionary) {
    self.title <- map.property("title")
    self.type <- map.property("type")
    self.items <- map.objects("items")
  }
}
