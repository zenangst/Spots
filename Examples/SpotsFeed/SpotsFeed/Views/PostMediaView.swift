import UIKit

public protocol PostMediaViewDelegate: class {

  func mediaDidTap(_ index: Int)
}

open class PostMediaView: UIView {

  public struct Dimensions {
    public static let containerOffset: CGFloat = 10
    public static let totalOffset: CGFloat = 20
    public static let height: CGFloat = 274
  }

  open lazy var firstImageView = UIImageView()
  open lazy var secondImageView = UIImageView()
  open lazy var thirdImageView = UIImageView()
  open lazy var firstTapGestureRecognizer = UITapGestureRecognizer()
  open lazy var secondTapGestureRecognizer = UITapGestureRecognizer()
  open lazy var thirdTapGestureRecognizer = UITapGestureRecognizer()
  open lazy var fourthTapGestureRecognizer = UITapGestureRecognizer()

  open lazy var imagesCountLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColor.white
    label.textAlignment = .center
    label.isOpaque = true

    return label
    }()

  open weak var delegate: PostMediaViewDelegate?

  // MARK: - Initialization

  public override init(frame: CGRect) {
    super.init(frame: frame)

    [firstImageView, secondImageView, thirdImageView].forEach {
      $0.contentMode = .scaleAspectFill
      $0.clipsToBounds = true
      $0.backgroundColor = UIColor.white
      $0.isOpaque = true
      $0.isUserInteractionEnabled = true
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
    backgroundColor = UIColor.white
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Actions

  open func handleGestureRecognizer(_ gesture: UITapGestureRecognizer) {
    var index = 2
    if gesture == firstTapGestureRecognizer {
      index = 0
    } else if gesture == secondTapGestureRecognizer {
      index = 1
    }
    delegate?.mediaDidTap(index)
  }

  // MARK: - Setup

  open func configureView(_ media: [Media]) {
    let totalWitdh = UIScreen.main.bounds.width
    let viewsArray = [firstImageView, secondImageView, thirdImageView]

    viewsArray.forEach { $0.removeFromSuperview() }

    for (index, element) in media.enumerated() where index < 3 {
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
