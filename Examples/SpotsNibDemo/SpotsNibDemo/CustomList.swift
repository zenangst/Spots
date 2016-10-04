import UIKit
import Brick
import Spots

open class CustomList: UITableViewCell, SpotConfigurable {

  @IBOutlet var toggle: UISwitch?
  @IBOutlet var titleLabel: UILabel?
  @IBOutlet var subtitleLabel: UILabel?
  open var preferredViewSize: CGSize = CGSize(width: 100, height: 60)

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    backgroundColor = UIColor.clear
  }

  open func configure(_ item: inout Item) {
    item.size.height = preferredViewSize.height
    titleLabel?.text = item.title
    subtitleLabel?.text = item.subtitle
    toggle?.isOn = item.meta("toggle", false)
  }
}
