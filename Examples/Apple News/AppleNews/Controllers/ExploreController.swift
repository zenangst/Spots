import Spots
import Brick
import Fakery

class ExploreController: SpotsController {

  convenience init(title: String) {
    let suggestedChannels = Component(span: 3, items: [
      Item(title: "Apple",   kind: Cell.Topic, image: ExploreController.suggestedImage(1)),
      Item(title: "Spotify", kind: Cell.Topic, image: ExploreController.suggestedImage(2)),
      Item(title: "Google",  kind: Cell.Topic, image: ExploreController.suggestedImage(3)),
      Item(title: "Apple",   kind: Cell.Topic, image: ExploreController.suggestedImage(4)),
      Item(title: "Spotify", kind: Cell.Topic, image: ExploreController.suggestedImage(5)),
      Item(title: "Google",  kind: Cell.Topic, image: ExploreController.suggestedImage(6)),
      Item(title: "Apple",   kind: Cell.Topic, image: ExploreController.suggestedImage(7)),
      Item(title: "Spotify", kind: Cell.Topic, image: ExploreController.suggestedImage(8)),
      Item(title: "Google",  kind: Cell.Topic, image: ExploreController.suggestedImage(9))
      ])

    let suggestedTopics = Component(span: 3, items: [
      Item(title: "Business", kind: Cell.Topic, meta: ["color" : "5A0E20"]),
      Item(title: "Software", kind: Cell.Topic, meta: ["color" : "760D26"]),
      Item(title: "News",     kind: Cell.Topic, meta: ["color" : "2266B5"]),
      Item(title: "iOS",      kind: Cell.Topic, meta: ["color" : "4CBCFB"])
      ])

    let browse = Component(title: "Browse", items: [
      Item(title: "News"),
      Item(title: "Business"),
      Item(title: "Politics"),
      Item(title: "Travel"),
      Item(title: "Technology"),
      Item(title: "Sports"),
      Item(title: "Science"),
      Item(title: "Entertainment"),
      Item(title: "Food")
      ], meta: ["headerHeight" : 33])

    let suggestedSpot = CarouselSpot(suggestedChannels)
    suggestedSpot.pageIndicator = true
    suggestedSpot.paginate = true
    suggestedSpot.paginateByItem = false

    let spots: [Spotable] = [
      ListSpot(component: Component(title : "Suggested Channels", meta: ["headerHeight" : 33])),
      suggestedSpot,
      ListSpot(component: Component(title : "Suggested Topics", meta: ["headerHeight" : 33])),
      CarouselSpot(suggestedTopics),
      ListSpot(component: browse)
    ]

    self.init(spots: spots)
    self.title = title
  }

  static func suggestedImage(id: Int) -> String {
    return Faker().internet.image(width: 125, height: 160) + "?item=\(id)"
  }

  static func topicImage(hex: String, id: Int) -> String {
    return Faker().internet.templateImage(width: 125, height: 160, backColorHex: hex, frontColorHex: hex) + "?item=\(id)"
  }
}
