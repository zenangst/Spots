import UIKit

public protocol PostMediaViewDelegate: class {

  func mediaDidTap(index: Int)
}

public class PostMediaView: UIView {

  public struct Dimensions {
    public static let containerOffset: CGFloat = 10
    public static let totalOffset: CGFloat = 20
    public static let height: CGFloat = 274
  }

  public lazy var firstImageView = UIImageView()
  public lazy var secondImageView = UIImageView()
  public lazy var thirdImageView = UIImageView()
  public lazy var firstTapGestureRecognizer = UITapGestureRecognizer()
  public lazy var secondTapGestureRecognizer = UITapGestureRecognizer()
  public lazy var thirdTapGestureRecognizer = UITapGestureRecognizer()
  public lazy var fourthTapGestureRecognizer = UITapGestureRecognizer()

  public lazy var imagesCountLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColor.whiteColor()
    label.textAlignment = .Center
    label.opaque = true

    return label
    }()

  public weak var delegate: PostMediaViewDelegate?

  // MARK: - Initialization

  public override init(frame: CGRect) {
    super.init(frame: frame)

    [firstImageView, secondImageView, thirdImageView].forEach {
      $0.contentMode = .ScaleAspectFill
      $0.clipsToBounds = true
      $0.backgroundColor = UIColor.whiteColor()
      $0.opaque = true
      $0.userInteractionEnabled = true
      $0.layer.drawsAsynchronously = true
    }

    [firstTapGestureRecognizer, secondTapGestureRecognizer,
      thirdTapGestureRecognizer, fourthTapGestureRecognizer].forEach {
        $0.addTarget(self, action: #selector(handleGestureRecognizer(_:)))
    }
    firstImageView.addGestureRecognizer(firstTapGestureRecognizer)
    secondImageView.addGestureRecognizer(secondTapGestureRecognizer)
    thirdImageView.addGestureRecognizer(thirdTapGestureRecognizer)
    imagesCountLabel.addGestureRecognizer(fourthTapGestureRecognizer)

    thirdImageView.addSubview(imagesCountLabel)
    backgroundColor = UIColor.whiteColor()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Actions

  public func handleGestureRecognizer(gesture: UITapGestureRecognizer) {
    var index = 2
    if gesture == firstTapGestureRecognizer {
      index = 0
    } else if gesture == secondTapGestureRecognizer {
      index = 1
    }
    delegate?.mediaDidTap(index)
  }

  // MARK: - Setup

  public func configureView(media: [Media]) {
    let totalWitdh = UIScreen.mainScreen().bounds.width
    let viewsArray = [firstImageView, secondImageView, thirdImageView]

    viewsArray.forEach { $0.removeFromSuperview() }

    for (index, element) in media.enumerate() where index < 3 {
      addSubview(viewsArray[index])
      viewsArray[index].setImage(element.thumbnail)
    }

    switch media.count {
    case 1:
      firstImageView.frame = CGRect(x: Dimensions.containerOffset, y: 0,
        width: totalWitdh - Dimensions.totalOffset, height: Dimensions.height)
    case 2:
      let imageSize = (totalWitdh - Dimensions.totalOffset) / 2

      firstImageView.frame = CGRect(x: Dimensions.containerOffset, y: 0,
        width: imageSize - 5, height: Dimensions.height)

      secondImageView.frame = CGRect(x: imageSize + 5 + Dimensions.containerOffset, y: 0,
        width: imageSize - 5, height: Dimensions.height)
    default:
      let smallImageSize = (totalWitdh - Dimensions.totalOffset) / 3
      let bigImageSize = smallImageSize * 2
      let smallOffset = bigImageSize + 5 + Dimensions.containerOffset

      firstImageView.frame = CGRect(x: Dimensions.containerOffset, y: 0,
        width: bigImageSize - 5, height: Dimensions.height)

      secondImageView.frame = CGRect(x: smallOffset, y: 0,
        width: smallImageSize - 5, height: Dimensions.height / 2 - 5)

      thirdImageView.frame = CGRect(x: smallOffset, y: Dimensions.height / 2 + 5,
        width: smallImageSize - 5, height: Dimensions.height / 2 - 5)

      imagesCountLabel.frame = thirdImageView.bounds
      imagesCountLabel.text = "+\(media.count - 3)"
      imagesCountLabel.alpha = media.count > 3 ? 1 : 0
    }
  }
}
