import UIKit
import Spots
import Brick

public protocol CommentTableViewCellDelegate: class {

  func commentAuthorDidTap(_ commentID: Int)
}

open class CommentTableViewCell: WallTableViewCell, SpotConfigurable {

  open var preferredViewSize: CGSize = CGSize(width: 0, height: 44)

  open class func height(_ item: Item) -> CGFloat {
    let post = item.post
    let postText = post.text as NSString
    let textFrame = postText.boundingRect(with: CGSize(
      width: UIScreen.main.bounds.width - Dimensions.textOffset - Dimensions.sideOffset,
      height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin,
      attributes: [ NSFontAttributeName : FontList.Comment.text ], context: nil)

    return 70.5 + textFrame.height
  }

  open static let reusableIdentifier = "CommentTableViewCell"

  public struct Dimensions {
    public static let sideOffset: CGFloat = 10
    public static let avatarSize: CGFloat = 40
    public static let textOffset: CGFloat = Dimensions.sideOffset * 2 + Dimensions.avatarSize
    public static let nameTopOffset: CGFloat = 12
    public static let dateTopOffset: CGFloat = 30
  }

  open lazy var avatarImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = Dimensions.avatarSize / 2
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.isOpaque = true
    imageView.backgroundColor = UIColor.white
    imageView.isUserInteractionEnabled = true

    return imageView
    }()

  open lazy var authorLabel: UILabel = {
    let label = UILabel()
    label.font = FontList.Comment.author

    return label
    }()

  open lazy var dateLabel: UILabel = {
    let label = UILabel()
    label.textColor = ColorList.Comment.date
    label.font = FontList.Comment.date

    return label
    }()

  open lazy var textView: UITextView = { [unowned self] in
    let textView = UITextView()
    textView.font = FontList.Comment.author
    textView.dataDetectorTypes = .link
    textView.isEditable = false
    textView.isScrollEnabled = false
    textView.delegate = self
    textView.textContainer.lineFragmentPadding = 0
    textView.textContainerInset = UIEdgeInsets.zero
    textView.linkTextAttributes = [
      NSForegroundColorAttributeName: ColorList.Basis.highlightedColor,
      NSUnderlineColorAttributeName: ColorList.Basis.highlightedColor,
      NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
    textView.subviews.first?.backgroundColor = ColorList.Comment.background

    return textView
    }()

  open lazy var bottomSeparator: CALayer = {
    let layer = CALayer()
    layer.backgroundColor = ColorList.Comment.background.cgColor
    layer.isOpaque = true

    return layer
    }()

  open lazy var imageTapGestureRecognizer: UITapGestureRecognizer = {
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: #selector(handleAuthorGestureRecognizer))

    return gesture
    }()

  open lazy var authorTapGestureRecognizer: UITapGestureRecognizer = {
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: #selector(handleAuthorGestureRecognizer))

    return gesture
    }()

  open weak var commentDelegate: CommentTableViewCellDelegate?

  // MARK: - Initialization

  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    let views: [UIView] = [avatarImageView, authorLabel, textView, dateLabel]
    views.forEach {
      addSubview($0)
      $0.isOpaque = true
      $0.backgroundColor = ColorList.Comment.background
    }

    backgroundColor = ColorList.Comment.background

    avatarImageView.addGestureRecognizer(imageTapGestureRecognizer)
    authorLabel.addGestureRecognizer(authorTapGestureRecognizer)

    layer.addSublayer(bottomSeparator)
    isOpaque = true
    selectionStyle = .none
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Actions

  open func handleAuthorGestureRecognizer() {
    guard let post = post else { return }
    commentDelegate?.commentAuthorDidTap(post.id)
  }

  // MARK: - Setup

  open func setupViews(_ item: Item) -> CGFloat {
    let post = item.post
    let totalWidth = UIScreen.main.bounds.width

    avatarImageView.frame = CGRect(x: Dimensions.sideOffset, y: Dimensions.sideOffset,
      width: Dimensions.avatarSize, height: Dimensions.avatarSize)
    if let avatarURL = post.author!.avatar {
      avatarImageView.setImage(avatarURL)
    }

    authorLabel.frame = CGRect(x: Dimensions.textOffset, y: Dimensions.nameTopOffset,
      width: totalWidth - 70, height: 20)
    authorLabel.text = post.author!.name

    textView.text = post.text
    textView.width = totalWidth - Dimensions.textOffset - Dimensions.sideOffset
    textView.sizeToFit()
    textView.frame = CGRect(x: Dimensions.textOffset, y: 36,
      width: textView.frame.width, height: textView.frame.height)

    dateLabel.frame = CGRect(x: Dimensions.textOffset, y: textView.frame.maxY + 9,
      width: textView.frame.width, height: 17)
    dateLabel.text = post.publishDate

    bottomSeparator.frame = CGRect(x: 0, y: dateLabel.frame.maxY + 8, width: totalWidth, height: 0.5)

    return bottomSeparator.frame.origin.y
  }

  open func configure(_ item: inout Item) {
    if bottomSeparator.frame.origin.y == 0.0 {
      item.size.width = contentView.frame.width
      item.size.height = setupViews(item)
    } else {
      item.size.height = CommentTableViewCell.height(item.post)
    }
  }
}

// MARK: - UITextViewDelegate

extension CommentTableViewCell: UITextViewDelegate {

  public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
    return true
  }
}
