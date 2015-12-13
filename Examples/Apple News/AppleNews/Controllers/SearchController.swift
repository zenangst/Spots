import Spots
import Sugar

class SearchController: SpotsController {

  convenience init(title: String) {

    let results = Component(title: "Search", kind: "search")

    let spots: [Spotable] = [
      ListSpot(component: results),
      TitleSpot(title: "Suggestions")
    ]

    self.init(spots: spots)
    self.title = title

    dispatch(queue: .Interactive) { [weak self] in
      let items = FavoritesController.generateItems(0, to: 4)
      self?.updateSpotAtIndex(1, closure: { (spot) -> Spotable in
        spot.component.items = items
        return spot
      })
    }

    if let spot = spotAtIndex(0) as? ListSpot,
      searchHeader = spot.cachedHeaders["search"] as? SearchHeaderView {
        searchHeader.searchField.delegate = self
    }
  }
}

extension SearchController: UITextFieldDelegate {

  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if textField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 1 &&
      string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {

        dispatch(queue: .Interactive) { [weak self] in
          let items = FavoritesController.generateItems(0, to: 4)
          self?.updateSpotAtIndex(1, closure: { (spot) -> Spotable in
            spot.component.title = "Suggestions"
            spot.component.items = items
            return spot
          })
        }
    } else if textField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 ||
      string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {

        dispatch(queue: .Interactive) { [weak self] in
          let items = FavoritesController.generateItems(0, to: 11)
          self?.updateSpotAtIndex(1, closure: { (spot) -> Spotable in
            spot.component.title = "Results"
            spot.component.items = items
            return spot
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
