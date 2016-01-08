import UIKit
//import Imaginary

public class ListSpotCell: UITableViewCell, Itemble {

  public var size = CGSize(width: 0, height: 44)
  public var item: ListItem?

  public override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(inout item: ListItem) {
    if let action = item.action where !action.isEmpty {
      accessoryType = .DisclosureIndicator
    } else {
      accessoryType = .None
    }

    detailTextLabel?.text = item.subtitle
    textLabel?.text = item.title

    if !item.image.isEmpty {
      if let url = NSURL(string: item.image) {
        //imageView?.setImage(url, placeholder: UIImage(named: "ImagePlaceholder"))
      } else {
        imageView?.image = UIImage(named: item.image)
      }
    }

    item.size.height = item.size.height > 0.0 ? item.size.height : size.height
  }
}
