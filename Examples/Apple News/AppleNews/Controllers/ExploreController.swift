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
      ListItem(title: "Business", kind: "topic", image: ExploreController.topicImage("5A0E20", id: 1)),
      ListItem(title: "Software", kind: "topic", image: ExploreController.topicImage("760D26", id: 2)),
      ListItem(title: "News",     kind: "topic", image: ExploreController.topicImage("2266B5", id: 3)),
      ListItem(title: "iOS",      kind: "topic", image: ExploreController.topicImage("4CBCFB", id: 4))
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
      TitleSpot(title: "Suggested Channels"),
      CarouselSpot(suggestedChannels,
        top: 5, left: 15, bottom: 5, right: 15, itemSpacing: 15),
      TitleSpot(title: "Suggested Topics"),
      CarouselSpot(suggestedTopics,
        top: 5, left: 15, bottom: 5, right: 15, itemSpacing: 15),
      ListSpot(component: browse)
    ]

    self.init(spots: spots, refreshable: false)
    self.title = title
  }

  static func suggestedImage(id: Int) -> String {
    return Faker().internet.image(width: 125, height: 160) + "?item=\(id)"
  }

  static func topicImage(hex: String, id: Int) -> String {
    return Faker().internet.templateImage(width: 125, height: 160, backColorHex: hex, frontColorHex: hex) + "?item=\(id)"
  }
}
