import UIKit
import Imaginary

public protocol PostAuthorViewDelegate: class {

  func authorDidTap()
}

public class PostAuthorView: UIView {

  public struct Dimensions {
    public static let avatarOffset: CGFloat = 10
    public static let avatarSize: CGFloat = 40
    public static let nameOffset: CGFloat = Dimensions.avatarOffset * 2 + Dimensions.avatarSize
    public static let nameTopOffset: CGFloat = 12
    public static let dateTopOffset: CGFloat = 30
  }

  public lazy var avatarImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = Dimensions.avatarSize / 2
    imageView.contentMode = .ScaleAspectFill
    imageView.clipsToBounds = true
    imageView.opaque = true
    imageView.backgroundColor = UIColor.whiteColor()

    return imageView
    }()

  public lazy var authorLabel: UILabel = {
    let label = UILabel()
    label.font = FontList.Post.author

    return label
    }()

  public lazy var dateLabel: UILabel = {
    let label = UILabel()
    label.textColor = ColorList.Post.date
    label.font = FontList.Post.date

    return label
    }()

  public lazy var tapAuthorGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: #selector(handleTapGestureRecognizer))

    return gesture
    }()

  public lazy var tapLabelGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: #selector(handleTapGestureRecognizer))

    return gesture
    }()

  public weak var delegate: PostAuthorViewDelegate?

  // MARK: - Initialization

  public override init(frame: CGRect) {
    super.init(frame: frame)

    [dateLabel, authorLabel, avatarImageView].forEach {
      addSubview($0)
      $0.opaque = true
      $0.backgroundColor = UIColor.whiteColor()
      $0.userInteractionEnabled = true
      $0.layer.drawsAsynchronously = true
    }

    avatarImageView.addGestureRecognizer(tapAuthorGestureRecognizer)
    authorLabel.addGestureRecognizer(tapLabelGestureRecognizer)
    backgroundColor = UIColor.whiteColor()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  public override func drawRect(rect: CGRect) {
    super.drawRect(rect)

    avatarImageView.frame = CGRect(x: Dimensions.avatarOffset, y: Dimensions.avatarOffset,
      width: Dimensions.avatarSize, height: Dimensions.avatarSize)
    authorLabel.frame = CGRect(x: Dimensions.nameOffset, y: Dimensions.nameTopOffset,
      width: UIScreen.mainScreen().bounds.width - 70, height: 20)
    dateLabel.frame = CGRect(x: Dimensions.nameOffset, y: Dimensions.dateTopOffset,
      width: UIScreen.mainScreen().bounds.width - 70, height: 17)
  }

  public func configureView(author: Author, date: String) {
    if let avatarURL = author.avatar {
      avatarImageView.setImage(avatarURL)
    }

    authorLabel.text = author.name
    dateLabel.text = date
  }

  // MARK: - Actions

  public func handleTapGestureRecognizer() {
    delegate?.authorDidTap()
  }
}
