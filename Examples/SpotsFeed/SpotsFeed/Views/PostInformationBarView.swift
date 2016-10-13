import UIKit

public protocol PostInformationBarViewDelegate: class {

  func likesInformationButtonDidPress()
  func commentInformationButtonDidPress()
  func seenInformationButtonDidPress()
}

open class PostInformationBarView: UIView {

  public struct Dimensions {
    public static let offset: CGFloat = 20
    public static let topOffset: CGFloat = 18
    public static let interitemOffset: CGFloat = 10
  }

  open lazy var likesButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.titleLabel?.font = FontList.Information.like
    button.setTitleColor(ColorList.Information.like, for: UIControlState())
    button.addTarget(self, action: #selector(likesButtonDidPress), for: .touchUpInside)

    return button
    }()

  open lazy var commentButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.titleLabel?.font = FontList.Information.comment
    button.setTitleColor(ColorList.Information.comment, for: UIControlState())
    button.addTarget(self, action: #selector(commentButtonDidPress), for: .touchUpInside)

    return button
    }()

  open lazy var seenButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.titleLabel?.font = FontList.Information.comment
    button.setTitleColor(ColorList.Information.seen, for: UIControlState())
    button.addTarget(self, action: #selector(seenButtonDidPress), for: .touchUpInside)

    return button
    }()

  open weak var delegate: PostInformationBarViewDelegate?

  // MARK: - Initialization

  public override init(frame: CGRect) {
    super.init(frame: frame)

    [likesButton, commentButton, seenButton].forEach {
      addSubview($0)
      $0.isOpaque = true
      $0.backgroundColor = UIColor.white
      $0.subviews.first?.isOpaque = true
      $0.subviews.first?.backgroundColor = UIColor.white
      $0.layer.drawsAsynchronously = true
    }

    backgroundColor = UIColor.white
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  open func configureView(_ likes: Int, comments: Int, seen: Int) {
    configureLikes(likes)
    configureComments(comments)
    configureSeen(seen)
  }

  open func configureLikes(_ likes: Int) {
    let title = likes == 0
      ? "" : String.localizedStringWithFormat(NSLocalizedString("%d like(s)", comment: ""), likes)

    likesButton.setTitle(title, for: UIControlState())
    likesButton.sizeToFit()
    likesButton.frame.origin = CGPoint(x: Dimensions.offset, y: Dimensions.topOffset)
  }

  open func configureComments(_ comments: Int) {
    let title = comments == 0
      ? "" : String.localizedStringWithFormat(NSLocalizedString("%d comment(s)", comment: ""), comments)
    let positionOffset: CGFloat = likesButton.title(for: UIControlState()) == ""
      ? Dimensions.offset : likesButton.frame.maxX + Dimensions.interitemOffset

    commentButton.setTitle(title, for: UIControlState())
    commentButton.sizeToFit()
    commentButton.frame.origin = CGPoint(x: positionOffset,
      y: Dimensions.topOffset)
  }

  open func configureSeen(_ seen: Int) {
    seenButton.setTitle("Seen by \(seen)", for: UIControlState())
    seenButton.sizeToFit()
    seenButton.frame.origin = CGPoint(x: UIScreen.main.bounds.width - seenButton.frame.width - Dimensions.offset,
      y: Dimensions.topOffset)
  }

  // MARK: - Actions

  open func likesButtonDidPress() {
    delegate?.likesInformationButtonDidPress()
  }

  open func commentButtonDidPress() {
    delegate?.commentInformationButtonDidPress()
  }

  open func seenButtonDidPress() {
    delegate?.seenInformationButtonDidPress()
  }
}
