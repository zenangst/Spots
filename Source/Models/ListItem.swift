import Tailor
import Sugar

protocol Listable { }

struct ListItem: Mappable, Listable {
  var title = ""
  var subtitle = ""
  var image = ""
  var type = ""
  var uri: String?

  init(_ map: JSONDictionary) {
    self.title <- map.property("title")
    self.subtitle <- map.property("subtitle")
    self.image <- map.property("image")
    self.type <- map.property("type")
    self.uri <- map.property("uri")
  }
}
