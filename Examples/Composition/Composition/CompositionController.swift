import Spots
import Brick

class CompositionController : Controller {

  static var components: [Component] {
    let json: [String : Any] = [
      "kind" : "composite",
      "children" : [
        [
          "kind" : "list",
          "items" : [
            ["title" : "foo"],
            ["title" : "bar"],
            ["title" : "baz"]
          ]
        ]
      ]
    ]

    let components = [
      Component(
        kind : Component.Kind.Grid.string,
        span: 2,
        items: [
          Item(json),
          Item(json)
        ]
      )]
    return components
  }

}
