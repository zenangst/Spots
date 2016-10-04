import UIKit
import Spots
import Brick

class ViewController: SpotsController {

  convenience init(title: String) {
    let featured = Component(items: [
      Item(title: "Whisper", image: "https://github.com/hyperoslo/Whisper/raw/master/Resources/whisper-cover.png", kind: Cell.Featured),
      Item(title: "Spots", image: "https://raw.githubusercontent.com/hyperoslo/Spots/master/Images/cover_v2.png", kind: Cell.Featured),
      Item(title: "Sync", image: "https://raw.githubusercontent.com/hyperoslo/Sync/master/Images/logo-v2.png", kind: Cell.Featured),
      ])

    let featuredOpensource = Component(span: 3, items: [
      Item(title: "ImagePicker", image: "https://github.com/hyperoslo/ImagePicker/raw/master/Resources/ImagePickerPresentation.png", kind: Cell.Grid),
      Item(title: "Spots", image: "https://raw.githubusercontent.com/hyperoslo/Spots/master/Images/cover_v2.png", kind: Cell.Grid),
      Item(title: "Cache", image: "https://github.com/hyperoslo/Cache/raw/master/Resources/CachePresentation.png", kind: Cell.Grid),
      ])

    let developers = Component(title: "Swift Developers @hyperoslo", items: [
      Item(title: "Vadym Markov", subtitle: "iOS Developer", image: "https://avatars2.githubusercontent.com/u/10529867?v=3&s=460", action: "1"),
      Item(title: "Ramon Gilabert Llop", subtitle: "iOS Developer", image: "https://avatars1.githubusercontent.com/u/6138120?v=3&s=460", action: "2"),
      Item(title: "Khoa Pham", subtitle: "iOS Developer", image: "https://avatars0.githubusercontent.com/u/2284279?v=3&s=460", action: "3"),
      Item(title: "Christoffer Winterkvist", subtitle: "iOS Developer", image: "https://avatars2.githubusercontent.com/u/57446?v=3&s=460", action: "4")
      ], meta: ["headerHeight" : 44])

    let spots: [Spotable] = [
      ListSpot(component: Component(title: "Spots for tvOS", meta: ["headerHeight" : 44])),
      CarouselSpot(featured, top: 0, left: 0, bottom: 30, right: 0, itemSpacing: 0),
      ListSpot(component: Component(title: "Open source by @hyperoslo", meta: ["headerHeight" : 44])),
      GridSpot(featuredOpensource, top: 30, left: 30, bottom: 30, right: 30, itemSpacing: -5),
      ListSpot(component: developers),
      ]

    self.init(spots: spots)
  }
}

