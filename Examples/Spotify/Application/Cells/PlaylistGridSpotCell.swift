import Spots
import Imaginary
import Sugar
import Brick

open class PlaylistGridSpotCell: UICollectionViewCell, SpotConfigurable {

  open var preferredViewSize: CGSize = CGSize(width: 125, height: 160)

  lazy var imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
  }

  lazy var albumView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
  }

  lazy var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

  override init(frame: CGRect) {
    super.init(frame: frame)

    [imageView, blurView, albumView].forEach { contentView.addSubview($0) }
    imageView.addObserver(self, forKeyPath: "image", options: [.new, .old], context: nil)
  }

  deinit {
    imageView.removeObserver(self, forKeyPath: "image")
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard let imageView = object as? UIImageView,
      let image = imageView.image, keyPath == "image" else { return }

    albumView.image = image
  }

  open func configure(_ item: inout Item) {
    optimize()
    backgroundColor = UIColor.clear

    if item.image.isPresent {
      imageView.setImage(URL(string: item.image))
      imageView.frame = contentView.frame
      blurView.frame = contentView.frame

      albumView.frame.size = CGSize(width: 128, height: 128)
      albumView.x = (frame.width - albumView.frame.width) / 2
      albumView.y = (frame.height - albumView.frame.height) / 2
    }

    item.size = preferredViewSize
  }
}
