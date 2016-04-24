import UIKit
import Spots
import Brick

class ViewController: SpotsController {

  convenience init(title: String) {
    let featured = Component(items: [
      ViewModel(title: "Whisper", image: "https://github.com/hyperoslo/Whisper/raw/master/Resources/whisper-cover.png", kind: Cell.Featured),
      ViewModel(title: "Spots", image: "https://raw.githubusercontent.com/hyperoslo/Spots/master/Images/cover_v2.png", kind: Cell.Featured),
      ViewModel(title: "Sync", image: "https://raw.githubusercontent.com/hyperoslo/Sync/master/Images/logo-v2.png", kind: Cell.Featured),
      ])

    let featuredOpensource = Component(span: 3, items: [
      ViewModel(title: "ImagePicker", image: "https://github.com/hyperoslo/ImagePicker/raw/master/Resources/ImagePickerPresentation.png", kind: Cell.Grid),
      ViewModel(title: "Spots", image: "https://raw.githubusercontent.com/hyperoslo/Spots/master/Images/cover_v2.png", kind: Cell.Grid),
      ViewModel(title: "Cache", image: "https://github.com/hyperoslo/Cache/raw/master/Resources/CachePresentation.png", kind: Cell.Grid),
      ])

    let developers = Component(title: "Swift Developers @hyperoslo", items: [
      ViewModel(title: "Vadym Markov", image: "https://avatars2.githubusercontent.com/u/10529867?v=3&s=460", subtitle: "iOS Developer", action: "1"),
      ViewModel(title: "Ramon Gilabert Llop", image: "https://avatars1.githubusercontent.com/u/6138120?v=3&s=460", subtitle: "iOS Developer", action: "2"),
      ViewModel(title: "Khoa Pham", image: "https://avatars0.githubusercontent.com/u/2284279?v=3&s=460", subtitle: "iOS Developer", action: "3"),
      ViewModel(title: "Christoffer Winterkvist", image: "https://avatars2.githubusercontent.com/u/57446?v=3&s=460", subtitle: "iOS Developer", action: "4")
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

