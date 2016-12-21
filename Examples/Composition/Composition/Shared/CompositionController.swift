import Spots
import Brick

class CompositionController : Controller, SpotsDelegate {

  static var components: [Component] {

    var mainComponent = Component(kind : "list")

    mainComponent.add(child: Component(
      kind: Component.Kind.Carousel.string,
      span: 1.0,
      items: [
        Item(title: "Whisper", image: "https://github.com/hyperoslo/Whisper/raw/master/Resources/whisper-cover.png", kind: "featured"),
        Item(title: "Spots", image: "https://raw.githubusercontent.com/hyperoslo/Spots/master/Images/cover_v2.png", kind: "featured"),
        Item(title: "Hue", image: "https://github.com/hyperoslo/Hue/raw/master/Images/cover.png", kind: "featured"),
        ]
      )
    )

    mainComponent.add(child: Component(
      kind: Component.Kind.Grid.string,
      span: 3.0,
      items: [
        Item(title: "ImagePicker", image: "https://github.com/hyperoslo/ImagePicker/raw/master/Resources/ImagePickerPresentation.png", kind: "grid"),
        Item(title: "Spots", image: "https://raw.githubusercontent.com/hyperoslo/Spots/master/Images/cover_v2.png", kind: "grid"),
        Item(title: "Cache", image: "https://github.com/hyperoslo/Cache/raw/master/Resources/CachePresentation.png", kind: "grid")
      ]
      )
    )

    #if os(tvOS)
      let span: Double = 2.0
    #endif

    #if os(iOS)
      let span: Double = 1.0
    #endif

    var developerComponent = Component(kind: "grid", span: span)

    developerComponent.add(children:
      [
        Component(
          kind: "list",
          items: [
            Item(title: "Vadym Markov", subtitle: "iOS Developer", image: "https://avatars2.githubusercontent.com/u/10529867?v=3&s=460", action: "1"),
            Item(title: "Ramon Gilabert Llop", subtitle: "iOS Developer", image: "https://avatars1.githubusercontent.com/u/6138120?v=3&s=460", action: "2")
          ]
        ),
        Component(
          kind: "list",
          items: [
            Item(title: "Khoa Pham", subtitle: "iOS Developer", image: "https://avatars0.githubusercontent.com/u/2284279?v=3&s=460", action: "3"),
            Item(title: "Christoffer Winterkvist", subtitle: "iOS Developer", image: "https://avatars2.githubusercontent.com/u/57446?v=3&s=460", action: "4")
          ]
        )
      ]
    )

    return [mainComponent, developerComponent]
  }

  func didSelect(item: Item, in spot: Spotable) {
    print(item)
  }
}
