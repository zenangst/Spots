import UIKit

public protocol PostActionBarViewDelegate: class {

  func likeButtonDidPress(_ liked: Bool)
  func commentButtonDidPress()
}

open class PostActionBarView: UIView {

  public struct Dimensions {
    public static let generalOffset: CGFloat = 10
    public static let separatorHeight: CGFloat = 0.5
  }

  open lazy var topSeparator: CALayer = {
    let layer = CALayer()
    layer.backgroundColor = ColorList.Basis.tableViewBackground.cgColor
    layer.isOpaque = true

    return layer
    }()

  open lazy var likeButton: UIButton = { [unowned self] in
    let button = UIButton(type: .custom)
    button.setTitle(NSLocalizedString("Like", comment: ""), for: UIControlState())
    button.titleLabel?.font = FontList.Action.like
    button.addTarget(self, action: #selector(likeButtonDidPress), for: .touchUpInside)
    button.subviews.first?.isOpaque = true
    button.subviews.first?.backgroundColor = UIColor.white

    return button
    }()

  open lazy var commentButton: UIButton = { [unowned self] in
    let button = UIButton(type: .custom)
    button.setTitle(NSLocalizedString("Comment", comment: ""), for: UIControlState())
    button.titleLabel?.font = FontList.Action.comment
    button.addTarget(self, action: #selector(commentButtonDidPress), for: .touchUpInside)
    button.setTitleColor(ColorList.Action.comment, for: UIControlState())
    button.subviews.first?.isOpaque = true
    button.subviews.first?.backgroundColor = UIColor.white

    return button
    }()

  open weak var delegate: PostActionBarViewDelegate?

  // MARK: - Initialization

  public override init(frame: CGRect) {
    super.init(frame: frame)

    [likeButton, commentButton].forEach {
      addSubview($0)
      $0.isOpaque = true
      $0.backgroundColor = UIColor.clear
      $0.layer.drawsAsynchronously = true
    }

    layer.addSublayer(topSeparator)
    backgroundColor = UIColor.white
  }

  // MARK: - Setup

  open override func draw(_ rect: CGRect) {
    super.draw(rect)

    let totalWidth = UIScreen.main.bounds.width

    topSeparator.frame = CGRect(x: Dimensions.generalOffset, y: 0,
      width: totalWidth - Dimensions.generalOffset * 2, height: Dimensions.separatorHeight)
    likeButton.frame = CGRect(x: Dimensions.generalOffset, y: Dimensions.separatorHeight,
      width: totalWidth / 2 - Dimensions.generalOffset, height: 43)
    commentButton.frame = CGRect(x: totalWidth / 2, y: Dimensions.separatorHeight,
      width: totalWidth / 2 - Dimensions.generalOffset, height: 43)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func configureView(_ liked: Bool) {
    let color = liked ? ColorList.Action.liked : ColorList.Action.like
    likeButton.setTitleColor(color, for: UIControlState())
  }

  // MARK: - Actions

  open func likeButtonDidPress() {
    let color = likeButton.titleColor(for: UIControlState()) == ColorList.Action.liked
      ? ColorList.Action.like : ColorList.Action.liked
    let liked = color == ColorList.Action.liked

    if liked {
      UIView.animate(withDuration: 0.1, animations: {
        self.likeButton.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        }, completion: { _ in
          UIView.animate(withDuration: 0.1, animations: {
            self.likeButton.transform = CGAffineTransform.identity
          })
      })
    }

    delegate?.likeButtonDidPress(liked)
    likeButton.setTitleColor(color, for: UIControlState())
  }

  open func commentButtonDidPress() {
    delegate?.commentButtonDidPress()
  }
}
