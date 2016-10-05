import Spots
import Sugar

class SearchController: SpotsController {

  convenience init(title: String) {
    let spots: [Spotable] = [
      ListSpot(component: Component(title: "Search", meta: ["headerHeight" : 44])),
      ListSpot(component: Component(kind: "search", meta: ["headerHeight" : 44])),
      ListSpot(component: Component(title: "Suggestions", meta: ["headerHeight" : 44])),
      ListSpot()
    ]

    self.init(spots: spots)
    self.title = title
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    dispatch(queue: .interactive) { [weak self] in
      let items = FavoritesController.generateItems(0, to: 4)
      self?.update(spotAtIndex: 2) { spot in
        spot.component.items = items
      }
    }

    if let headerView = spot(1, ListSpot.self)?.tableView.headerView(forSection: 0),
      let searchHeader = headerView as? SearchHeaderView {
      searchHeader.searchField.delegate = self
    }
  }
}

extension SearchController: UITextFieldDelegate {

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField.text?.lengthOfBytes(using: String.Encoding.utf8) == 1 &&
      string.lengthOfBytes(using: String.Encoding.utf8) == 0 {

        dispatch(queue: .interactive) { [weak self] in
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
    } else if (textField.text?.lengthOfBytes(using: String.Encoding.utf8))! > 0 ||
      string.lengthOfBytes(using: String.Encoding.utf8) > 0 {

        dispatch(queue: .interactive) { [weak self] in

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

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
