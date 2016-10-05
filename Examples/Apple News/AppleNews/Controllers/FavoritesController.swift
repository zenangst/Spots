import Spots
import Fakery
import Sugar
import Brick

class FavoritesController: SpotsController {

  static let faker = Faker()

  convenience init(title: String) {
    self.init()
    self.title = title
  }

  static func generateItem(_ index: Int, kind: Cell = Cell.Topic) -> Item {
    let item = Item(
      title: faker.commerce.department(),
      subtitle: faker.lorem.sentences(amount: 2),
      image: faker.internet.image(width: 125, height: 160) + "?type=avatar&id=\(index)",
      kind: kind)

    return item
  }

  static func generateItems(_ from: Int, to: Int, kind: Cell = Cell.Topic) -> [Item] {
    var items = [Item]()
    for i in from...from+to {
      autoreleasepool { items.append(generateItem(i, kind: kind)) }
    }
    return items
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    showContent()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if navigationController?.navigationBar.topItem?.rightBarButtonItem == nil {
      navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .organize,
        target: self,
        action: #selector(showContent))
    }
  }

  func showContent() {
    let newType = spot(0, Spotable.self)?.component.kind == "grid" ? "list" : "grid"

    navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: newType == "grid" ? .organize : .action,
      target: self,
      action: #selector(showContent))

    reload([
      "components" : [
        [
        "kind" : newType,
        "span" : 3
        ]
      ]
    ], animated: { view in
      view.alpha = 0.0
      view.transform = CGAffineTransform(scaleX: 1.0, y: 0.0)
      UIView.animate(withDuration: 0.3) {
        view.alpha = 1.0
        view.transform = CGAffineTransform.identity
      }
    }) {
      dispatch(queue: .interactive) { [weak self] in
        let items = FavoritesController.generateItems(0, to: 11, kind: newType == "grid" ? Cell.Topic : Cell.Feed)
        self?.update { spot in
          spot.component.items = items
        }
      }
    }
  }
}
