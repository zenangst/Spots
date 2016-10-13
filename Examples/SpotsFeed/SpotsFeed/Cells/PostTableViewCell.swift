import UIKit
import Spots
import Brick

public protocol PostActionDelegate: class {

  func likeButtonDidPress(_ postID: Int)
  func commentsButtonDidPress(_ postID: Int)
}

public protocol PostInformationDelegate: class {

  func likesInformationDidPress(_ postID: Int)
  func commentsInformationDidPress(_ postID: Int)
  func seenInformationDidPress(_ postID: Int)
  func authorDidTap(_ postID: Int)
  func mediaDidTap(_ postID: Int, kind: Media.Kind, index: Int)
}

open class PostTableViewCell: WallTableViewCell, SpotConfigurable {

  open var preferredViewSize: CGSize = CGSize(width: 0, height: 44)

  open static let reusableIdentifier = "PostTableViewCell"

  open class func height(_ item: Item) -> CGFloat {
    let post = item.post
    let postText = post.text as NSString
    let textFrame = postText.boundingRect(with: CGSize(width: UIScreen.main.bounds.width - 40,
      height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin,
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

  open lazy var authorView: PostAuthorView = { [unowned self] in
    let view = PostAuthorView()
    view.delegate = self

    return view
    }()

  open lazy var postMediaView: PostMediaView = { [unowned self] in
    let view = PostMediaView()
    view.delegate = self

    return view
    }()

  open lazy var textView: UITextView = { [unowned self] in
    let textView = UITextView()
    textView.font = FontList.Post.text
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
    textView.subviews.first?.backgroundColor = UIColor.white

    return textView
    }()

  open lazy var informationView: PostInformationBarView = { [unowned self] in
    let view = PostInformationBarView()
    view.delegate = self

    return view
    }()

  open lazy var actionBarView: PostActionBarView = { [unowned self] in
    let view = PostActionBarView()
    view.delegate = self

    return view
    }()

  open lazy var bottomSeparator: UIView = {
    let view = UIView()
    return view
    }()

  open weak var actionDelegate: PostActionDelegate?
  open weak var informationDelegate: PostInformationDelegate?

  // MARK: - Initialization

  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    [authorView, postMediaView, textView,
      informationView, actionBarView, bottomSeparator].forEach {
        contentView.addSubview($0)
        backgroundColor = UIColor.white
    }

    bottomSeparator.backgroundColor = ColorList.Basis.tableViewBackground
    isOpaque = true
    selectionStyle = .none
    addGestureRecognizer(tapGestureRecognizer)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func setupViews(_ item: Item) -> CGFloat {
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

    authorView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60)
    postMediaView.frame = CGRect(x: 0, y: imageTop, width: UIScreen.main.bounds.width, height: imageHeight)
    informationView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: informationHeight)
    actionBarView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 44)
    bottomSeparator.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20)

    authorView.configureView(post.author!, date: post.publishDate)
    informationView.configureView(post.likeCount, comments: post.commentCount, seen: post.seenCount)
    actionBarView.configureView(post.liked)

    textView.text = post.text
    textView.width = UIScreen.main.bounds.width - 40
    textView.sizeToFit()
    textView.frame = CGRect(x: 20, y: postMediaView.frame.maxY + 12,
      width: textView.frame.width, height: textView.frame.height)

    informationView.frame.origin = CGPoint(x: 0, y: textView.frame.maxY)
    actionBarView.frame.origin = CGPoint(x: 0, y: informationView.frame.maxY)
    bottomSeparator.y = (actionBarView.frame).maxY

    return bottomSeparator.y
  }

  open func configure(_ item: inout Item) {
    item.size.width = contentView.frame.width
    item.size.height = setupViews(item)
    item.size.height = ceil(PostTableViewCell.height(item))
  }
}

// MARK: - UITextViewDelegate

extension PostTableViewCell: UITextViewDelegate {

  public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
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

  public func likeButtonDidPress(_ liked: Bool) {
    if liked {
      performAction(withURN: "feed:action:like:1")
    } else {
      performAction(withURN: "feed:action:unlike:1")
    }

    guard let post = post else { return }

    post.liked = liked
    post.likeCount += liked ? 1 : -1

    informationView.configureLikes(post.likeCount)
    informationView.configureComments(post.commentCount)
    delegate?.updateCellSize(post.id, liked: liked)
  }

  public func commentButtonDidPress() {
    performAction(withURN: "feed:comment:1")
  }
}

// MARK: - PostAuthorViewDelegate

extension PostTableViewCell: PostAuthorViewDelegate {

  public func authorDidTap() {
    performAction(withURN: "feed:author:1")
  }
}

extension PostTableViewCell: PostMediaViewDelegate {

  public func mediaDidTap(_ index: Int) {
    performAction(withURN: "feed:media:1")
  }
}
