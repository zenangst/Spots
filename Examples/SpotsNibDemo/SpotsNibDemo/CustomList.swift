import UIKit
import Brick
import Spots

public class CustomList: UITableViewCell, SpotConfigurable {

  @IBOutlet var toggle: UISwitch?
  @IBOutlet var titleLabel: UILabel?
  @IBOutlet var subtitleLabel: UILabel?
  public var size = CGSize(width: 100, height: 60)

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    backgroundColor = UIColor.clearColor()
  }

  public func configure(inout item: ViewModel) {
    item.size.height = size.height
    titleLabel?.text = item.title
    subtitleLabel?.text = item.subtitle
    toggle?.on = item.meta("toggle", false)
  }
}
