import Tailor
import Sugar

protocol Listable { }

struct ListItem: Mappable, Listable {
  var title = ""
  var subtitle = ""
  var image = ""
  var kind = ""
  var uri: String?

  init(_ map: JSONDictionary) {
    title    <- map.property("title")
    subtitle <- map.property("subtitle")
    image    <- map.property("image")
    kind     <- map.property("type")
    uri      <- map.property("uri")
  }
}
