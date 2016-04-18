import Spots
import Compass
import Keychain
import Sugar
import Brick

class SearchController: SpotsController {

  let accessToken = Keychain.password(forAccount: keychainAccount)

  lazy var serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL)

  convenience init(title: String) {
    self.init(spots: [
      ListSpot(component: Component(title: "Search", kind: "search", meta: ["headerHeight" : 44])),
      ListSpot(),
      ListSpot()
      ])
    self.title = title
    self.spotsDelegate = self

    guard let spot = spot as? ListSpot,
      searchHeader = spot.cachedHeaders["search"] as? SearchHeaderView else { return }

    searchHeader.searchField.delegate = self
  }

  override func scrollViewDidScroll(scrollView: UIScrollView) {
    super.scrollViewDidScroll(scrollView)

    guard let spot = spot as? ListSpot,
      searchHeader = spot.cachedHeaders["search"] as? SearchHeaderView else { return }

    searchHeader.searchField.resignFirstResponder()
  }
}

extension SearchController: SpotsDelegate {

  func spotDidSelectItem(spot: Spotable, item: ViewModel) {
    guard let urn = item.action else { return }

    guard let delegate = UIApplication.sharedApplication().delegate as? AppDelegate,
      carouselSpot = delegate.mainController.playerController.spot(1, CarouselSpot.self) else { return }

      delegate.mainController.playerController.update(spotAtIndex: 1) {
        var item = item
        item.kind = "featured"
        item.size = CGSize(
          width: UIScreen.mainScreen().bounds.width,
          height: UIScreen.mainScreen().bounds.width)
        $0.items = [item]
      }

      delegate.mainController.playerController.lastItem = item
      carouselSpot.scrollTo { item.action == $0.action }

    Compass.navigate(urn)
  }
}

extension SearchController: UITextFieldDelegate {

  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if textField.text?.length == 1 && string.length == 0 {
        if spot(1, Spotable.self)?.component.title == "Results" {
          update(spotAtIndex: 1) { spot in
            spot.component.title = ""
          }

          update(spotAtIndex: 2) { $0.items = [] }
        }
    } else if textField.text?.length > 0 || string.length > 0 {
        if spot(1, Spotable.self)?.component.title == "" {
          update(spotAtIndex: 1) { spot in
            spot.component.title = "Results"
          }
        }

        guard let text = textField.text else { return true }

        dispatch(queue: .Custom(serialQueue)) {
          SPTSearch.performSearchWithQuery("\(text)\(string)", queryType: .QueryTypeTrack, accessToken: self.accessToken, callback: { (error, object) -> Void in
            if let object = object {
              guard let object = object as? SPTListPage
                where object.items != nil && object.items.count > 0
                else { return }

              var viewModels = [ViewModel]()

              object.items.enumerate().forEach { index, item in
                guard let item = item as? SPTPartialTrack else { return }

                guard let artist = ((item.artists as! [SPTPartialArtist]).first)?.name,
                  image = (item.album as SPTPartialAlbum).largestCover
                  else { return }

                viewModels.append(ViewModel(
                  title: item.name,
                  subtitle:  "\(artist) - \((item.album as SPTPartialAlbum).name)",
                  image: image.imageURL.absoluteString,
                  kind: "playlist",
                  action: "song:" + item.playableUri.absoluteString.replace(":", with: "_"),
                  meta: [
                    "notification" : "\(item.name) by \(artist)",
                    "track" : item.name,
                    "artist" : artist,
                    "image" : image.imageURL.absoluteString
                  ]
                  ))
              }
              self.update(spotAtIndex: 2) { $0.items = viewModels }
            }
          })
        }
    }

    return true
  }

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }
}
