import Spots
import Imaginary
import Sugar

public class FeaturedGridSpotCell: UICollectionViewCell, Itemble {

  public var size = CGSize(width: 100, height: 120)

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFill

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
    backgroundColor = UIColor.clearColor()

    if !item.image.isEmpty {
      imageView.setImage(NSURL(string: item.image))
      imageView.frame.size = frame.size
    }

    item.size = size
  }

}
