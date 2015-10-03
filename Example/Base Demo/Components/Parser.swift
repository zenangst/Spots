import UIKit

struct Parser {

  static func parse(json: [String : AnyObject]) -> [Component] {
    guard let components = json["components"] as? [[String : AnyObject]] else { return [Component]() }

    var views = [Component]()

    for component in components {
      if let type = component["type"] as? String,
      items = component["items"] as? [AnyObject] where type == "list" {
        var componentItems = [ListItem]()
        for item in items {
          if let title = item["title"] as? String,
          subtitle = item["subtitle"] as? String,
          image = item["image"] as? String,
            type = item["type"] as? String {
              var uri: String?
              if let target = item["target"] as? [String : String] {
                uri = target["uri"]
              }
              let listItem = ListItem(title: title, subtitle: subtitle, image: image, type: type, uri: uri)
              componentItems.append(listItem)
          }
        }

        let listComponent = ListComponent(items: componentItems)
        views.append(listComponent)
      }
    }

    return views
  }

}
