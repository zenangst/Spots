import Spots
import Compass
import Keychain
import Sugar

class SearchController: SpotsController {

  let accessToken = Keychain.password(forAccount: keychainAccount)

  convenience init(title: String) {
    let component = Component(title: "Search", kind: "search")
    let spots: [Spotable] = [
      ListSpot(component: component),
      ListSpot(title: ""),
      ListSpot()
    ]

    self.init(spots: spots)
    self.title = title
    self.spotsDelegate = self

    if let spot = spot as? ListSpot,
      searchHeader = spot.cachedHeaders["search"] as? SearchHeaderView {
        searchHeader.searchField.delegate = self
    }
  }

  override func scrollViewDidScroll(scrollView: UIScrollView) {
    super.scrollViewDidScroll(scrollView)

    if let spot = spot as? ListSpot,
      searchHeader = spot.cachedHeaders["search"] as? SearchHeaderView {
        searchHeader.searchField.resignFirstResponder()
    }
  }
}

extension SearchController: SpotsDelegate {

  func spotDidSelectItem(spot: Spotable, item: ListItem) {
    guard let urn = item.action else { return }

    if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate,
    carouselSpot = delegate.mainController.playerController.spot(1) as? CarouselSpot {

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
    }

    Compass.navigate(urn)
  }
}

extension SearchController: UITextFieldDelegate {

  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if textField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 1 &&
      string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {

        dispatch(queue: .Interactive) { [weak self] in

          if self?.spot(1)?.component.title == "Results" {
            self?.update(spotAtIndex: 1) { spot in
              spot.component.title = ""
            }
          }
        }
    } else if textField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 ||
      string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {

        dispatch(queue: .Interactive) { [weak self] in

          guard let weakSelf = self else { return }

          if weakSelf.spot(1)?.component.title == "" {
            weakSelf.update(spotAtIndex: 1) { spot in
              spot.component.title = "Results"
            }
          }

          guard let text = textField.text else { return }

          SPTSearch.performSearchWithQuery("\(text)\(string)", queryType: .QueryTypeTrack, accessToken: weakSelf.accessToken, callback: { (error, object) -> Void in
            if let object = object {
              guard let object = object as? SPTListPage
                where object.items != nil && object.items.count > 0
                else { return }

              var listItems = [ListItem]()

              object.items.enumerate().forEach { index, item in
                guard let item = item as? SPTPartialTrack else { return }

                guard let artist = ((item.artists as! [SPTPartialArtist]).first)?.name,
                image = (item.album as SPTPartialAlbum).largestCover
                  else { return }

                listItems.append(ListItem(
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
              weakSelf.update(spotAtIndex: 2) { $0.items = listItems }
            }
          })
        }
    }

    return true
  }

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
