import UIKit

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

public class PostTableViewCell: WallTableViewCell, Itemble {

  public var size = CGSize(width: 0, height: 44)

  public static let reusableIdentifier = "PostTableViewCell"

  public class func height(item: ListItem) -> CGFloat {
    let post = PostTableViewCell.itemToPost(item)
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
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private class func itemToPost(item: ListItem) -> Post {
    let avatarURL = NSURL(string: item.image)!
    let author = Author(name: item.title, avatar: avatarURL)

    var mediaItems = [Media]()
    if let strings = item.meta["media"] as? [String] {
      for mediaString in strings {
        let url = NSURL(string: mediaString)!
        let media = Media(kind: Media.Kind.Image, source: url)
        mediaItems.append(media)
      }
    }
    return Post(id: 0, text: item.subtitle, publishDate: "", author: author, media: mediaItems)
  }

  public func setupViews(item: ListItem) -> CGFloat {
    let post = PostTableViewCell.itemToPost(item)
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
    textView.frame.size.width = UIScreen.mainScreen().bounds.width - 40
    textView.sizeToFit()
    textView.frame = CGRect(x: 20, y: CGRectGetMaxY(postMediaView.frame) + 12,
      width: textView.frame.width, height: textView.frame.height)

    informationView.frame.origin = CGPoint(x: 0, y: CGRectGetMaxY(textView.frame))
    actionBarView.frame.origin = CGPoint(x: 0, y: CGRectGetMaxY(informationView.frame))
    bottomSeparator.frame.origin.y = CGRectGetMaxY(actionBarView.frame)

    return bottomSeparator.frame.origin.y
  }

  public func configure(inout item: ListItem) {
    let post = PostTableViewCell.itemToPost(item)
    if bottomSeparator.frame.origin.y == 0.0 {
      item.size.width = contentView.frame.width
      item.size.height = setupViews(item)
    } else {
      item.size.height = PostTableViewCell.height(item)
    }
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
    guard let post = post else { return }

    post.liked = liked
    post.likeCount += liked ? 1 : -1

    informationView.configureLikes(post.likeCount)
    informationView.configureComments(post.commentCount)
    delegate?.updateCellSize(post.id, liked: liked)
    actionDelegate?.likeButtonDidPress(post.id)
  }

  public func commentButtonDidPress() {
    guard let post = post else { return }
    actionDelegate?.commentsButtonDidPress(post.id)
  }
}

// MARK: - PostAuthorViewDelegate

extension PostTableViewCell: PostAuthorViewDelegate {

  public func authorDidTap() {
    guard let post = post else { return }
    informationDelegate?.authorDidTap(post.id)
  }
}

extension PostTableViewCell: PostMediaViewDelegate {

  public func mediaDidTap(index: Int) {
    guard let post = post, firstMedia = post.media.first else { return }
    informationDelegate?.mediaDidTap(post.id, kind: firstMedia.kind, index: index)
  }
}
