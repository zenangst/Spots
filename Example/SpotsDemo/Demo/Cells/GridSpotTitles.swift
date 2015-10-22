import UIKit
import GoldenRetriever
import Sugar

class GridSpotCellTitles : UICollectionViewCell, Itemble {

  var size = CGSize(width: 88, height: 120)

  lazy var titleLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: self.contentView.frame)
    label.textColor = UIColor.blackColor()
    label.textAlignment = .Center
    label.autoresizingMask = [.FlexibleWidth]
    label.font = UIFont(name: "AvenirNext-Bold", size: 34)
    label.numberOfLines = 2
    return label
    }()

  lazy var subtitleLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: self.contentView.frame)
    label.textColor = UIColor.blackColor()
    label.textAlignment = .Center
    label.autoresizingMask = [.FlexibleWidth]
    label.font = UIFont(name: "SanFranciscoDisplay-Medium", size: 18)
    label.textColor = UIColor(red:0.933, green:0.459, blue:0.200, alpha: 1)
    label.numberOfLines = 3
    return label
    }()

  func configure(inout item: ListItem) {
    if titleLabel.superview == nil {
      titleLabel.text = item.title
      titleLabel.sizeToFit()
      addSubview(titleLabel)
    }

    if subtitleLabel.superview == nil {
      subtitleLabel.text = item.subtitle
      subtitleLabel.sizeToFit()
      subtitleLabel.frame.origin.y = titleLabel.frame.size.height + titleLabel.frame.origin.y
      subtitleLabel.frame.size.width = contentView.frame.size.width
      subtitleLabel.frame.size.height += 20
      addSubview(subtitleLabel)
    }

    item.size.height = subtitleLabel.frame.origin.y + subtitleLabel.frame.height
  }
}
