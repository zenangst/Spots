import UIKit

public protocol WallTableViewCellDelegate: class {

  func cellDidTap(id: Int)
  func updateCellSize(postID: Int, liked: Bool)
}

public class WallTableViewCell: UITableViewCell {

  public class func height(post: Post) -> CGFloat {
    return 44
  }

  public lazy var tapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: #selector(handleTapGestureRecognizer))

    return gesture
    }()

  public var post: Post?
  public weak var delegate: WallTableViewCellDelegate?

  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    addGestureRecognizer(tapGestureRecognizer)
    layer.drawsAsynchronously = true
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  public func configureCell(post: Post) {
    self.post = post
  }

  // MARK: - Actions

  public func handleTapGestureRecognizer() {
    action("feed:post:1")
  }
}
