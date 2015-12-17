import Spots
import Sugar
import Compass

class MainController: UINavigationController {

  lazy var recentController: FeaturedController = {
    let controller = FeaturedController(title: "Your music".uppercaseString)
    return controller
  }()

  lazy var player: PlayerView = {
    let view = PlayerView()
    return view
  }()

  override func viewDidLoad() {
    viewControllers = [recentController]
    recentController.container.contentInset.bottom = 44

    view.addSubview(player)
  }
}
