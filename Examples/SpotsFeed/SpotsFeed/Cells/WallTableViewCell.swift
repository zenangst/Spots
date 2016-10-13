import UIKit

public protocol WallTableViewCellDelegate: class {

  func cellDidTap(_ id: Int)
  func updateCellSize(_ postID: Int, liked: Bool)
}

open class WallTableViewCell: UITableViewCell {

  open class func height(_ post: Post) -> CGFloat {
    return 44
  }

  open lazy var tapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: #selector(handleTapGestureRecognizer))

    return gesture
    }()

  open var post: Post?
  open weak var delegate: WallTableViewCellDelegate?

  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    addGestureRecognizer(tapGestureRecognizer)
    layer.drawsAsynchronously = true
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  open func configureCell(_ post: Post) {
    self.post = post
  }

  // MARK: - Actions

  open func handleTapGestureRecognizer() {
    performAction(withURN: "feed:post:1")
  }
}
