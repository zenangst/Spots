import Spots
import Sugar
import Compass

class MainController: UINavigationController {

  lazy var featuredController = FeaturedController(title: "Featured music".uppercaseString)
  lazy var player = PlayerView(frame: UIScreen.mainScreen().bounds)

  override func viewDidLoad() {
    viewControllers = [featuredController]
    featuredController.container.contentInset.bottom = 44

    player.frame.origin.y = UIScreen.mainScreen().bounds.height - 60
    view.addSubview(player)
  }
}
