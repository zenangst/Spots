import UIKit
import Spots
import Brick

public protocol PostActionDelegate: class {

  func likeButtonDidPress(postID: Int)
  func commentsButtonDidPress(postID: Int)
}

public protocol PostInformationDelegate: class {

  func likesInformationDidPress(postID: Int)
  func commentsInformationDidPress(postID: Int)
  func seenInformationDidPress(postID: Int)
  func authorDidTap(postID: Int)
  func mediaDidTap(postID: Int, kind: Media.Kind, index: Int)
}

public class PostTableViewCell: WallTableViewCell, SpotConfigurable {

  public var size = CGSize(width: 0, height: 44)

  public static let reusableIdentifier = "PostTableViewCell"

  public class func height(item: ViewModel) -> CGFloat {
    let post = item.post
    let postText = post.text as NSString
    let textFrame = postText.boundingRectWithSize(CGSize(width: UIScreen.mainScreen().bounds.width - 40,
      height: CGFloat.max), options: .UsesLineFragmentOrigin,
      attributes: [ NSFontAttributeName : FontList.Post.text ], context: nil)

    var imageHeight: CGFloat = 274
    var imageTop: CGFloat = 60
    if post.media.isEmpty {
      imageHeight = 0
      imageTop = 50
    }

    var informationHeight: CGFloat = 56
    if post.likeCount == 0 && post.commentCount == 0 {
      informationHeight = 16
    }

    return imageHeight + imageTop + informationHeight + 44 + 20 + 12 + textFrame.height
  }

  public lazy var authorView: PostAuthorView = { [unowned self] in
    let view = PostAuthorView()
    view.delegate = self

    return view
    }()

  public lazy var postMediaView: PostMediaView = { [unowned self] in
    let view = PostMediaView()
    view.delegate = self

    return view
    }()

  public lazy var textView: UITextView = { [unowned self] in
    let textView = UITextView()
    textView.font = FontList.Post.text
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
    textView.subviews.first?.backgroundColor = UIColor.whiteColor()

    return textView
    }()

  public lazy var informationView: PostInformationBarView = { [unowned self] in
    let view = PostInformationBarView()
    view.delegate = self

    return view
    }()

  public lazy var actionBarView: PostActionBarView = { [unowned self] in
    let view = PostActionBarView()
    view.delegate = self

    return view
    }()

  public lazy var bottomSeparator: UIView = {
    let view = UIView()
    return view
    }()

  public weak var actionDelegate: PostActionDelegate?
  public weak var informationDelegate: PostInformationDelegate?

  // MARK: - Initialization

  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    [authorView, postMediaView, textView,
      informationView, actionBarView, bottomSeparator].forEach {
        contentView.addSubview($0)
        backgroundColor = UIColor.whiteColor()
    }

    bottomSeparator.backgroundColor = ColorList.Basis.tableViewBackground
    opaque = true
    selectionStyle = .None
    addGestureRecognizer(tapGestureRecognizer)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func setupViews(item: ViewModel) -> CGFloat {
    let post = item.post
    var imageHeight: CGFloat = 0
    var imageTop: CGFloat = 50
    if !post.media.isEmpty {
      imageHeight = 274
      imageTop = 60
      postMediaView.configureView(post.media)
      postMediaView.alpha = 1
    } else {
      postMediaView.alpha = 0
    }

    var informationHeight: CGFloat = 56
    if post.likeCount == 0 && post.commentCount == 0 {
      informationHeight = 16
    }

    authorView.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 60)
    postMediaView.frame = CGRect(x: 0, y: imageTop, width: UIScreen.mainScreen().bounds.width, height: imageHeight)
    informationView.frame.size = CGSize(width: UIScreen.mainScreen().bounds.width, height: informationHeight)
    actionBarView.frame.size = CGSize(width: UIScreen.mainScreen().bounds.width, height: 44)
    bottomSeparator.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 20)

    authorView.configureView(post.author!, date: post.publishDate)
    informationView.configureView(post.likeCount, comments: post.commentCount, seen: post.seenCount)
    actionBarView.configureView(post.liked)

    textView.text = post.text
    textView.width = UIScreen.mainScreen().bounds.width - 40
    textView.sizeToFit()
    textView.frame = CGRect(x: 20, y: CGRectGetMaxY(postMediaView.frame) + 12,
      width: textView.frame.width, height: textView.frame.height)

    informationView.frame.origin = CGPoint(x: 0, y: CGRectGetMaxY(textView.frame))
    actionBarView.frame.origin = CGPoint(x: 0, y: CGRectGetMaxY(informationView.frame))
    bottomSeparator.y = CGRectGetMaxY(actionBarView.frame)

    return bottomSeparator.y
  }

  public func configure(inout item: ViewModel) {
    item.size.width = contentView.frame.width
    item.size.height = setupViews(item)
    item.size.height = ceil(PostTableViewCell.height(item))
  }
}

// MARK: - UITextViewDelegate

extension PostTableViewCell: UITextViewDelegate {

  public func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
    return true
  }
}

// MARK: - PostInformationBarViewDelegate

extension PostTableViewCell: PostInformationBarViewDelegate {

  public func likesInformationButtonDidPress() {
    guard let post = post else { return }
    informationDelegate?.likesInformationDidPress(post.id)
  }

  public func commentInformationButtonDidPress() {
    guard let post = post else { return }
    informationDelegate?.commentsInformationDidPress(post.id)
  }

  public func seenInformationButtonDidPress() {
    guard let post = post else { return }
    informationDelegate?.seenInformationDidPress(post.id)
  }
}

// MARK: - PostActionBarViewDelegate

extension PostTableViewCell: PostActionBarViewDelegate {

  public func likeButtonDidPress(liked: Bool) {
    if liked {
      action("feed:action:like:1")
    } else {
      action("feed:action:unlike:1")
    }

    guard let post = post else { return }

    post.liked = liked
    post.likeCount += liked ? 1 : -1

    informationView.configureLikes(post.likeCount)
    informationView.configureComments(post.commentCount)
    delegate?.updateCellSize(post.id, liked: liked)
  }

  public func commentButtonDidPress() {
    action("feed:comment:1")
  }
}

// MARK: - PostAuthorViewDelegate

extension PostTableViewCell: PostAuthorViewDelegate {

  public func authorDidTap() {
    action("feed:author:1")
  }
}

extension PostTableViewCell: PostMediaViewDelegate {

  public func mediaDidTap(index: Int) {
    action("feed:media:1")
  }
}
