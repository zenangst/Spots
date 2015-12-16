import Spots

class MainController: UINavigationController {

  lazy var playlistController: PlaylistController = {
    let spot = ListSpot(component: Component())
    let controller = PlaylistController(playlistID: nil)
    controller.title = "Playlists"

    return controller
  }()

  override func viewDidLoad() {
    viewControllers = [playlistController]
  }

}
