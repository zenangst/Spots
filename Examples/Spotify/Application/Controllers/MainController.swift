import Spots
import Sugar
import Compass

class MainController: UINavigationController {

  var initialOrigin: CGFloat = UIScreen.mainScreen().bounds.height - 60

  lazy var recentController: FeaturedController = {
    let controller = FeaturedController(title: "Your music".uppercaseString)
    return controller
  }()

  lazy var player: UIView = { [unowned self] in
    let bounds = UIScreen.mainScreen().bounds
    let view = UIView(frame: CGRect(
      x: 0, y: self.initialOrigin,
      width: bounds.width, height: bounds.height))
    view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.9)

    return view
  }()

  lazy var albumCover: UIImageView = { [unowned self] in
    let size = UIScreen.mainScreen().bounds.width - 40
    let imageView = UIImageView(frame: CGRect(x: 20, y: 80, width: size, height: size))
    imageView.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.7)

    return imageView
  }()

  lazy var albumTrack: UILabel = { [unowned self] in
    let size = UIScreen.mainScreen().bounds.width - 40
    let label = UILabel(frame: CGRect(x: 20, y: CGRectGetMaxY(self.albumCover.frame) + 20,
      width: size, height: 60))
    label.font = UIFont.systemFontOfSize(24)
    label.textColor = UIColor.whiteColor()
    label.textAlignment = .Center

    return label
    }()

  lazy var albumArtist: UILabel = { [unowned self] in
    let size = UIScreen.mainScreen().bounds.width - 40
    let label = UILabel(frame: CGRect(x: 20, y: CGRectGetMaxY(self.albumTrack.frame),
      width: size, height: 60))
    label.font = UIFont.systemFontOfSize(16)
    label.textColor = UIColor.whiteColor()
    label.textAlignment = .Center

    return label
    }()

  lazy var smallAlbumTrack: UILabel = { [unowned self] in
    let size = UIScreen.mainScreen().bounds.width - 40
    let label = UILabel(frame: CGRect(x: 20, y: 0,
      width: size, height: 40))
    label.font = UIFont.boldSystemFontOfSize(12)
    label.textColor = UIColor.whiteColor()
    label.textAlignment = .Center
    label.text = "-"

    return label
    }()

  lazy var smallAlbumArtist: UILabel = { [unowned self] in
    let size = UIScreen.mainScreen().bounds.width - 40
    let label = UILabel(frame: CGRect(x: 20, y: 30,
      width: size, height: 20))
    label.font = UIFont.systemFontOfSize(10)
    label.textColor = UIColor.whiteColor()
    label.textAlignment = .Center
    label.text = "-"

    return label
    }()

  lazy var actionButton: UIButton = { [unowned self] in
    let button = UIButton(frame: CGRect(x: 0, y: 5, width: 44, height: 44))
    button.setImage(self.stopButton, forState: .Normal)
    button.addTarget(self, action: "stop", forControlEvents: .TouchUpInside)
    button.tintColor = UIColor.whiteColor()

    return button
  }()

  lazy var panRecognizer: UIPanGestureRecognizer = { [unowned self] in
    let recognizer = UIPanGestureRecognizer()
    recognizer.addTarget(self, action: "handlePanGesture:")
    return recognizer
    }()

  lazy var tapRecognizer: UITapGestureRecognizer = { [unowned self] in
    let recognizer = UITapGestureRecognizer()
    recognizer.addTarget(self, action: "handleTapGesture:")
    return recognizer
  }()

  let playButton: UIImage? = UIImage(named: "playButton")?.imageWithRenderingMode(.AlwaysTemplate)
  let stopButton: UIImage? = UIImage(named: "stopButton")?.imageWithRenderingMode(.AlwaysTemplate)

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  override func viewDidLoad() {
    viewControllers = [recentController]
    recentController.container.contentInset.bottom = 44
    player.addGestureRecognizer(panRecognizer)
    player.addGestureRecognizer(tapRecognizer)
    player.addSubview(actionButton)
    player.addSubview(albumCover)
    player.addSubview(albumTrack)
    player.addSubview(albumArtist)
    player.addSubview(smallAlbumTrack)
    player.addSubview(smallAlbumArtist)
    view.addSubview(player)

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePlayer:", name: "updatePlayer", object: nil)
  }

  func updatePlayer(notification: NSNotification) {
    print(notification.userInfo)
    if let userInfo = notification.userInfo,
      track = userInfo["track"] as? String,
      artist = userInfo["artist"] as? String,
      image = userInfo["image"] as? String {
        smallAlbumTrack.text = track
        smallAlbumArtist.text = artist

        albumCover.setImage(NSURL(string: image))
        albumTrack.text = track
        albumArtist.text = artist
    }
  }

  func stop() {
    Compass.navigate("stop")
  }

  func handleTapGesture(gesture: UITapGestureRecognizer) {
    let minimumY: CGFloat = 60
    let maximumY: CGFloat = UIScreen.mainScreen().bounds.height - 60

    if player.frame.origin.y == maximumY {
      UIView.animateWithDuration(0.2, delay: 0, options: [.AllowUserInteraction], animations: {
        self.player.frame.origin.y = minimumY
        }, completion: nil)
    }
  }

  func handlePanGesture(gesture: UIPanGestureRecognizer) {
    let minimumY: CGFloat = 60
    let maximumY: CGFloat = UIScreen.mainScreen().bounds.height - 60
    let translation = gesture.translationInView(view)
    let velocity = gesture.velocityInView(view)

    switch gesture.state {
    case .Began:
      initialOrigin = player.frame.origin.y
    case .Changed:
      if initialOrigin + translation.y < minimumY {
        player.frame.origin.y = minimumY
      } else if player.frame.origin.y > maximumY {
        player.frame.origin.y = maximumY
      } else if player.frame.origin.y <= maximumY {
        player.frame.origin.y = initialOrigin + translation.y
      }
    case .Ended, .Cancelled:
      var endY: CGFloat = 0

      if velocity.y <= 0 {
        endY = minimumY
      } else {
        endY = maximumY
      }

      var time = maximumY / abs(velocity.y)
      if time > 1 {
        time = 0.7
      }

      UIView.animateWithDuration(NSTimeInterval(time), delay: 0, options: [.AllowUserInteraction], animations: {
        self.player.frame.origin.y = endY
        }, completion: nil)


    default: break
    }
  }
}
