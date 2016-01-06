import Spots
import Fakery

class ExploreController: SpotsController {

  convenience init(title: String) {
    let suggestedChannels = Component(span: 3, items: [
      ListItem(title: "Apple",   kind: "topic", image: ExploreController.suggestedImage(1)),
      ListItem(title: "Spotify", kind: "topic", image: ExploreController.suggestedImage(2)),
      ListItem(title: "Google",  kind: "topic", image: ExploreController.suggestedImage(3))
      ])

    let suggestedTopics = Component(span: 3, items: [
      ListItem(title: "Business", kind: "topic", meta: ["color" : "5A0E20"]),
      ListItem(title: "Software", kind: "topic", meta: ["color" : "760D26"]),
      ListItem(title: "News",     kind: "topic", meta: ["color" : "2266B5"]),
      ListItem(title: "iOS",      kind: "topic", meta: ["color" : "4CBCFB"])
      ])

    let browse = Component(title: "Browse", items: [
      ListItem(title: "News"),
      ListItem(title: "Business"),
      ListItem(title: "Politics"),
      ListItem(title: "Travel"),
      ListItem(title: "Technology"),
      ListItem(title: "Sports"),
      ListItem(title: "Science"),
      ListItem(title: "Entertainment"),
      ListItem(title: "Food")
      ])

    let spots: [Spotable] = [
      ListSpot(title: "Suggested Channels"),
      CarouselSpot(suggestedChannels,
        top: 5, left: 15, bottom: 5, right: 15, itemSpacing: 15),
      ListSpot(title: "Suggested Topics"),
      CarouselSpot(suggestedTopics,
        top: 5, left: 15, bottom: 5, right: 15, itemSpacing: 15),
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
