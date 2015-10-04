import UIKit
import Sugar

struct Parser {

  static func parse(json: JSONDictionary) -> [ComponentView] {
    guard let components = json["components"] as? JSONArray else { return [ComponentView]() }
    var views = [ComponentView]()
    for component in components {
      if let type = component["type"] as? String,
      items = component["items"] as? [JSONDictionary] where type == "list" {
        var componentItems = [ListItem]()
        for json in items {
          componentItems.append(ListItem(json: json))
        }

        views.append(ListComponent(items: componentItems))
      }
    }
    
    return views
  }
}
