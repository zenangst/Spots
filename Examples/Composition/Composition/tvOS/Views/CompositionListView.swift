import UIKit
import Spots
import Brick

class CompositionListView: UITableViewCell, SpotConfigurable {

  var preferredViewSize: CGSize = CGSize(width: 0, height: 120)

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(_ item: inout Item) {
    textLabel?.text = item.title
    detailTextLabel?.text = item.subtitle
  }
}
