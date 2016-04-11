import Spots
import Imaginary
import Sugar
import Brick

public class PlaylistGridSpotCell: UICollectionViewCell, SpotConfigurable {

  public var size = CGSize(width: 125, height: 160)

  lazy var imageView = UIImageView().then {
    $0.contentMode = .ScaleAspectFill
  }

  lazy var albumView = UIImageView().then {
    $0.contentMode = .ScaleAspectFill
  }

  lazy var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))

  override init(frame: CGRect) {
    super.init(frame: frame)

    [imageView, blurView, albumView].forEach { addSubview($0) }
    imageView.addObserver(self, forKeyPath: "image", options: [.New, .Old], context: nil)
  }

  deinit {
    imageView.removeObserver(self, forKeyPath: "image")
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    guard let imageView = object as? UIImageView,
      image = imageView.image
      where keyPath == "image" else { return }

    albumView.image = image
  }

  public func configure(inout item: ViewModel) {
    backgroundColor = UIColor.clearColor()

    if item.image.isPresent {
      imageView.setImage(NSURL(string: item.image))
      imageView.frame.size = frame.size
      blurView.frame.size = frame.size

      albumView.frame.size = CGSize(width: 128, height: 128)
      albumView.x = (frame.width - albumView.frame.width) / 2
      albumView.y = (frame.height - albumView.frame.height) / 2
    }

    item.size = size
  }
}
