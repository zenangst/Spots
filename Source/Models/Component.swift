import Tailor
import Sugar

struct Component: Mappable {
  var title = ""
  var kind = ""
  var span = 1
  var items = [ListItem]()

  init(_ map: JSONDictionary) {
    title <- map.property("title")
    kind  <- map.property("type")
    span  <- map.property("span")
    items <- map.objects("items")
  }
}
