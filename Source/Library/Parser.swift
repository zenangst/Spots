import UIKit
import Sugar

struct Parser {

  static func parse(json: JSONDictionary) -> [Component] {
    guard let components = json["components"] as? JSONArray else { return [Component]() }
    var views = [Component]()
    for component in components {
      if let title = component["title"] as? String,
      type = component["type"] as? String,
      items = component["items"] as? [JSONDictionary] where type == "list" {
        var componentItems = [ListItem]()
        for json in items {
          componentItems.append(ListItem(json: json))
        }

        views.append(ListComponent(title: title, items: componentItems))
      }
    }
    
    return views
  }
}
