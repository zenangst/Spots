import UIKit
import Compass

class PlayerView: UIView {

  let screenBounds = UIScreen.mainScreen().bounds
  var initialOrigin: CGFloat = UIScreen.mainScreen().bounds.height - 60

  lazy var albumCover: UIImageView = { [unowned self] in
    let size = UIScreen.mainScreen().bounds.width
    let imageView = UIImageView(frame: CGRect(x: 0, y: 60, width: size, height: size))
    imageView.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.7)

    return imageView
    }()

  lazy var albumTrack: UILabel = { [unowned self] in
    let size = UIScreen.mainScreen().bounds.width - 40
    let label = UILabel(frame: CGRect(x: 20, y: CGRectGetMaxY(self.albumCover.frame) + 0,
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

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.frame.size.height += 60

    backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.9)

    [panRecognizer, tapRecognizer].forEach { addGestureRecognizer($0) }
    [actionButton, albumCover, albumTrack, albumArtist, smallAlbumTrack, smallAlbumArtist]
      .forEach {
        addSubview($0)
    }

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePlayer:", name: "updatePlayer", object: nil)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  func updatePlayer(notification: NSNotification) {
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

  func handleTapGesture(gesture: UITapGestureRecognizer) {
    let minimumY: CGFloat = 60
    let maximumY: CGFloat = UIScreen.mainScreen().bounds.height - 60

    if frame.origin.y == maximumY {
      UIView.animateWithDuration(0.2, delay: 0, options: [.AllowUserInteraction], animations: {
        self.frame.origin.y = minimumY
        }, completion: nil)
    }
  }

  func handlePanGesture(gesture: UIPanGestureRecognizer) {
    let minimumY: CGFloat = -60
    let maximumY: CGFloat = UIScreen.mainScreen().bounds.height - 60
    let translation = gesture.translationInView(self)
    let velocity = gesture.velocityInView(self)

    switch gesture.state {
    case .Began:
      initialOrigin = frame.origin.y
    case .Changed:
      if initialOrigin + translation.y < minimumY {
        frame.origin.y = minimumY
      } else if frame.origin.y > maximumY {
        frame.origin.y = maximumY
      } else if frame.origin.y <= maximumY {
        frame.origin.y = initialOrigin + translation.y
      }
    case .Ended, .Cancelled:
      let endY = velocity.y <= 0 ? minimumY : maximumY
      var time = maximumY / abs(velocity.y)
      if time > 1 {
        time = 0.7
      }

      UIView.animateWithDuration(NSTimeInterval(time), delay: 0, options: [.AllowUserInteraction], animations: {
        self.frame.origin.y = endY
        UIApplication.sharedApplication().statusBarHidden = endY == minimumY
        }, completion: { _ in
      })

    default: break
    }
  }

  func stop() {
    Compass.navigate("stop")
  }
}
