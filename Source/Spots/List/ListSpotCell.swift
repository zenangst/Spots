import UIKit

public class ListSpotCell: UITableViewCell, Itemble {

  var size = CGSize(width: 0, height: 44)

  public override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(inout item: ListItem) {
    if item.title == "Espen Almdahl" {
      item.size.height = 200
    }
  }
}
