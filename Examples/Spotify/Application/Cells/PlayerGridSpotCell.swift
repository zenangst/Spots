import Spots
import Imaginary
import Sugar

public class PlayerGridSpotCell: UICollectionViewCell, Itemble {

  public var size = CGSize(width: 125, height: 80)

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFill
    imageView.tintColor = UIColor.whiteColor()

    return imageView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(imageView)
    imageView.addObserver(self, forKeyPath: "image", options: [.New, .Old], context: nil)
  }

  deinit {
    imageView.removeObserver(self, forKeyPath: "image")
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

    if let imageView = object as? UIImageView,
      image = imageView.image
      where keyPath == "image" {
        dispatch(queue: .Interactive) {
          let (background, _, _, _) = image.colors(CGSize(width: 128, height: 128))
          dispatch { [weak self] in
            guard let background = background else { return }
            self?.backgroundColor = background
          }
        }
    }
  }

  public func configure(inout item: ListItem) {
    backgroundColor = UIColor.redColor()

    if !item.image.isEmpty {
      imageView.image = UIImage(named: item.image)?.imageWithRenderingMode(.AlwaysTemplate)
//      imageView.setImage(NSURL(string: item.image))
//      imageView.frame.size = frame.size
//      blurView.frame.size = frame.size
//      albumView.setImage(NSURL(string: item.image))
//      albumView.frame.size = CGSize(width: 128, height: 128)
//      albumView.frame.origin.x = (frame.width - albumView.frame.width) / 2
//      albumView.frame.origin.y = (frame.height - albumView.frame.height) / 2
    }

    item.size = size
  }

}
