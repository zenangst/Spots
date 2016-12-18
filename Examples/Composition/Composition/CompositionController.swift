import Spots
import Brick

class CompositionController : Controller {

  static var components: [Component] {
    let json: [String : Any] = [
      "kind" : "composite",
      "children" : [
        [
          "kind" : "list",
          "header" : "header",
          "title" : "foo bar baz",
          "items" : [
            ["title" : "foo", "kind" : "view", "size" : ["height" : 88.0]],
            ["title" : "bar", "kind" : "view", "size" : ["height" : 88.0]],
            ["title" : "baz", "kind" : "view", "size" : ["height" : 88.0]],
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
