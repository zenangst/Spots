import Tailor
import Sugar

struct Component: Mappable {
  var title = ""
  var type = ""
  var span = 1
  var items = [ListItem]()

  init(_ map: JSONDictionary) {
    self.title <- map.property("title")
    self.type <- map.property("type")
    self.span <- map.property("span")
    self.items <- map.objects("items")
  }
}
