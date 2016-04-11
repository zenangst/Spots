import UIKit
import Spots
import Brick

public protocol CommentTableViewCellDelegate: class {

  func commentAuthorDidTap(commentID: Int)
}

public class CommentTableViewCell: WallTableViewCell, SpotConfigurable {

  public var size = CGSize(width: 0, height: 44)

  public class func height(item: ViewModel) -> CGFloat {
    let post = item.post
    let postText = post.text as NSString
    let textFrame = postText.boundingRectWithSize(CGSize(
      width: UIScreen.mainScreen().bounds.width - Dimensions.textOffset - Dimensions.sideOffset,
      height: CGFloat.max), options: .UsesLineFragmentOrigin,
      attributes: [ NSFontAttributeName : FontList.Comment.text ], context: nil)

    return 70.5 + textFrame.height
  }

  public static let reusableIdentifier = "CommentTableViewCell"

  public struct Dimensions {
    public static let sideOffset: CGFloat = 10
    public static let avatarSize: CGFloat = 40
    public static let textOffset: CGFloat = Dimensions.sideOffset * 2 + Dimensions.avatarSize
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
    imageView.userInteractionEnabled = true

    return imageView
    }()

  public lazy var authorLabel: UILabel = {
    let label = UILabel()
    label.font = FontList.Comment.author

    return label
    }()

  public lazy var dateLabel: UILabel = {
    let label = UILabel()
    label.textColor = ColorList.Comment.date
    label.font = FontList.Comment.date

    return label
    }()

  public lazy var textView: UITextView = { [unowned self] in
    let textView = UITextView()
    textView.font = FontList.Comment.author
    textView.dataDetectorTypes = .Link
    textView.editable = false
    textView.scrollEnabled = false
    textView.delegate = self
    textView.textContainer.lineFragmentPadding = 0
    textView.textContainerInset = UIEdgeInsetsZero
    textView.linkTextAttributes = [
      NSForegroundColorAttributeName: ColorList.Basis.highlightedColor,
      NSUnderlineColorAttributeName: ColorList.Basis.highlightedColor,
      NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
    textView.subviews.first?.backgroundColor = ColorList.Comment.background

    return textView
    }()

  public lazy var bottomSeparator: CALayer = {
    let layer = CALayer()
    layer.backgroundColor = ColorList.Comment.background.CGColor
    layer.opaque = true

    return layer
    }()

  public lazy var imageTapGestureRecognizer: UITapGestureRecognizer = {
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: #selector(handleAuthorGestureRecognizer))

    return gesture
    }()

  public lazy var authorTapGestureRecognizer: UITapGestureRecognizer = {
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: #selector(handleAuthorGestureRecognizer))

    return gesture
    }()

  public weak var commentDelegate: CommentTableViewCellDelegate?

  // MARK: - Initialization

  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    [avatarImageView, authorLabel, textView, dateLabel].forEach {
      addSubview($0)
      $0.opaque = true
      $0.backgroundColor = ColorList.Comment.background
    }

    backgroundColor = ColorList.Comment.background

    avatarImageView.addGestureRecognizer(imageTapGestureRecognizer)
    authorLabel.addGestureRecognizer(authorTapGestureRecognizer)

    layer.addSublayer(bottomSeparator)
    opaque = true
    selectionStyle = .None
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Actions

  public func handleAuthorGestureRecognizer() {
    guard let post = post else { return }
    commentDelegate?.commentAuthorDidTap(post.id)
  }

  // MARK: - Setup

  public func setupViews(item: ViewModel) -> CGFloat {
    let post = item.post
    let totalWidth = UIScreen.mainScreen().bounds.width

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

  public func configure(inout item: ViewModel) {
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

  public func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
    return true
  }
}
