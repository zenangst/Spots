import Spots
import Compass
import Keychain
import Sugar
import Brick

class SearchController: SpotsController {

  let accessToken = Keychain.password(forAccount: keychainAccount)

  lazy var serialQueue = DispatchQueue(label: "serial", qos: DispatchQoS.userInteractive, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)

  convenience init(title: String) {
    self.init(spots: [
      ListSpot(component: Component(title: "Search", kind: "search", meta: ["headerHeight" : 88])),
      ListSpot(),
      ListSpot()
      ])
    self.title = title
    self.spotsDelegate = self

    guard let headerView = spot(0, ListSpot.self)?.tableView.headerView(forSection: 0),
      let searchHeader = headerView as? SearchHeaderView else { return }

    searchHeader.searchField.delegate = self
  }

  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    super.scrollViewDidScroll(scrollView)

    guard let headerView = spot(0, ListSpot.self)?.tableView.headerView(forSection: 0),
      let searchHeader = headerView as? SearchHeaderView else { return }
    searchHeader.searchField.resignFirstResponder()
  }
}

extension SearchController: SpotsDelegate {

  func spotDidSelectItem(_ spot: Spotable, item: Item) {
    guard let urn = item.action else { return }

    guard let delegate = UIApplication.shared.delegate as? AppDelegate,
      let carouselSpot = delegate.mainController.playerController.spot(1, CarouselSpot.self) else { return }

      delegate.mainController.playerController.update(spotAtIndex: 1) {
        var item = item
        item.kind = "featured"
        item.size = CGSize(
          width: UIScreen.main.bounds.width,
          height: UIScreen.main.bounds.width)
        $0.items = [item]
      }

      delegate.mainController.playerController.lastItem = item
      carouselSpot.scrollTo { item.action == $0.action }

    Compass.navigate(to: urn)
  }
}

extension SearchController: UITextFieldDelegate {

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField.text?.length == 1 && string.length == 0 {
        if spot(1, Spotable.self)?.component.title == "Results" {
          update(spotAtIndex: 1) { spot in
            spot.component.title = ""
          }

          update(spotAtIndex: 2) { $0.items = [] }
        }
    } else if (textField.text?.length)! > 0 || string.length > 0 {
        if spot(1, Spotable.self)?.component.title == "" {
          update(spotAtIndex: 1) { spot in
            spot.component.title = "Results"
          }
        }

        guard let text = textField.text else { return true }

        dispatch(queue: .custom(serialQueue)) {
          SPTSearch.perform(withQuery: "\(text)\(string)", queryType: .queryTypeTrack, accessToken: self.accessToken, callback: { (error, object) -> Void in
            if let object = object {
              guard let object = object as? SPTListPage
                , object.items != nil && object.items.count > 0
                else { return }

              var viewModels = [Item]()

              object.items.enumerated().forEach { index, item in
                guard let item = item as? SPTPartialTrack else { return }

                guard let artist = ((item.artists as! [SPTPartialArtist]).first)?.name,
                  let image = (item.album as SPTPartialAlbum).largestCover
                  else { return }

                viewModels.append(Item(
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

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }
}
