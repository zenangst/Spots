import Spots
import Sugar

class SearchController: SpotsController {

  convenience init(title: String) {

    let results = Component(title: "Search", kind: "search", meta: ["headerHeight" : 44])

    let spots: [Spotable] = [
      ListSpot(component: results),
      ListSpot(component: Component(title: "Suggestions", meta: ["headerHeight" : 44])),
      ListSpot()
    ]

    self.init(spots: spots)
    self.title = title
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    dispatch(queue: .Interactive) { [weak self] in
      let items = FavoritesController.generateItems(0, to: 4)
      self?.update(spotAtIndex: 2) { spot in
        spot.component.items = items
      }
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

          if self?.spot(1, Spotable.self)?.component.title == "Results" {
            self?.update(spotAtIndex: 1) { spot in
              spot.component.title = "Suggestions"
            }
          }

          self?.update(spotAtIndex: 2) { spot in
            spot.component.items = items
          }
        }
    } else if textField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 ||
      string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {

        dispatch(queue: .Interactive) { [weak self] in

          if self?.spot(1, Spotable.self)?.component.title == "Suggestions" {
            self?.update(spotAtIndex: 1) { spot in
              spot.component.title = "Results"
            }
          }

          let items = FavoritesController.generateItems(0, to: 11)
          self?.update(spotAtIndex: 2) { spot in
            spot.component.items = items
          }
        }
    }

    return true
  }

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
