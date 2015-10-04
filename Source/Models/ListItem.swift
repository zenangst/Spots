import Tailor
import Sugar

struct ListItem {
  var title = ""
  var subtitle = ""
  var image = ""
  var type = ""
  var uri: String?

  init(json: JSONDictionary) {
    self.title <- json.property("title")
    self.subtitle <- json.property("subtitle")
    self.image <- json.property("image")
    self.type <- json.property("type")
    self.uri <- json.property("uri")
  }
}
