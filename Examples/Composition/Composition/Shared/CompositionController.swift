import Spots
import Brick

class CompositionController : Controller, SpotsDelegate {

  static var components: [Component] {

    let items1: [[String : Any]] = [
      ["title" : "First", "kind" : "view", "size" : ["height" : 66.0]],
      ["title" : "Second", "kind" : "view", "size" : ["height" : 66.0]],
      ["title" : "Third", "kind" : "view", "size" : ["height" : 66.0]]
    ]
    let items2: [[String : Any]] = [
      ["title" : "Forth", "kind" : "view", "size" : ["height" : 66.0]],
      ["title" : "Fifth", "kind" : "view", "size" : ["height" : 66.0]],
      ["title" : "Sixt", "kind" : "view", "size" : ["height" : 66.0]]
    ]

    let items3: [[String : Any]] = [
      ["title" : "Seventh", "kind" : "view", "size" : ["height" : 66.0]],
      ["title" : "Eight", "kind" : "view", "size" : ["height" : 66.0]],
      ["title" : "Ninth", "kind" : "view", "size" : ["height" : 66.0]]
    ]

    let json1: [String : Any] = [
      "kind" : "composite",
      "children" : [
        [
          "kind" : "list",
          "header" : "header",
          "title" : "First Header",
          "items" : items1
        ]
      ]
    ]

    let json2: [String : Any] = [
      "kind" : "composite",
      "children" : [
        [
          "kind" : "list",
          "header" : "header",
          "title" : "Second Header",
          "items" : items2
        ]
      ]
    ]

    let json3: [String : Any] = [
      "kind" : "composite",
      "children" : [
        [
          "kind" : "list",
          "header" : "header",
          "title" : "Third Header",
          "items" : items3
        ]
      ]
    ]

    let components = [
      Component(
        title: "The very first Header",
        header: "header",
        kind: Component.Kind.List.string,
        items: [
          Item(title: "foo", kind: "view", size: CGSize(width: 0, height: 66)),
          Item(title: "bar", kind: "view", size: CGSize(width: 0, height: 66)),
          Item(title: "baz", kind: "view", size: CGSize(width: 0, height: 66))
        ]
      ),
      Component(
        kind : Component.Kind.Grid.string,
        span: 2,
        items: [
          Item(json1),
          Item(json2)
        ]
      ),
      Component(
        kind : Component.Kind.Grid.string,
        span: 3,
        items: [
          Item(json1),
          Item(json2),
          Item(json3)
        ]
      )
    ]
    return components
  }

  func didSelect(item: Item, in spot: Spotable) {
    print(item)
  }
}
