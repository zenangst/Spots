import Spots
import Sugar

class SearchController: SpotsController {

  convenience init(title: String) {

    let results = Component(title: "Search", kind: "search")

    let spots: [Spotable] = [
      ListSpot(component: results),
      ListSpot(title: "Suggestions"),
      ListSpot()
    ]

    self.init(spots: spots)
    self.title = title

    dispatch(queue: .Interactive) { [weak self] in
      let items = FavoritesController.generateItems(0, to: 4)
      self?.update(spotAtIndex: 2, closure: { (spot) -> Spotable in
        spot.component.items = items
        return spot
      })
    }

    if let spot = spot as? ListSpot,
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

          if self?.spot(1)?.component.title == "Results" {
            self?.update(spotAtIndex: 1, closure: { (spot) -> Spotable in
              spot.component.title = "Suggestions"
              return spot
            })
          }

          self?.update(spotAtIndex: 2, closure: { (spot) -> Spotable in
            spot.component.items = items
            return spot
          })
        }
    } else if textField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 ||
      string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {

        dispatch(queue: .Interactive) { [weak self] in

          if self?.spot(1)?.component.title == "Suggestions" {
            self?.update(spotAtIndex: 1, closure: { (spot) -> Spotable in
              spot.component.title = "Results"
              return spot
            })
          }

          let items = FavoritesController.generateItems(0, to: 11)
          self?.update(spotAtIndex: 2, closure: { (spot) -> Spotable in
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
