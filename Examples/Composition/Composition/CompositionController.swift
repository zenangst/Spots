import Spots
import Brick

class CompositionController : Controller, SpotsDelegate {

  static var components: [Component] {

    let items: [[String : Any]] = [
      ["title" : "foo", "kind" : "view", "size" : ["height" : 88.0]],
      ["title" : "bar", "kind" : "view", "size" : ["height" : 88.0]],
      ["title" : "baz", "kind" : "view", "size" : ["height" : 88.0]]
    ]

    let json1: [String : Any] = [
      "kind" : "composite",
      "children" : [
        [
          "kind" : "list",
          "header" : "header",
          "title" : "foo bar baz",
          "items" : items
        ]
      ]
    ]

    let json2: [String : Any] = [
      "kind" : "composite",
      "children" : [
        [
          "kind" : "list",
          "header" : "header",
          "title" : "foo bar baz",
          "items" : items
        ]
      ]
    ]

    let components = [
      Component(
        kind : Component.Kind.Grid.string,
        span: 2,
        items: [
          Item(json1),
          Item(json2)
        ]
      )]
    return components
  }

  func didSelect(item: Item, in spot: Spotable) {
    print(item)
  }
}
