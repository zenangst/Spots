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
    label.textAlignment = .Justified
    label.autoresizingMask = [.FlexibleWidth]
    label.font = UIFont.systemFontOfSize(16)
    label.textColor = UIColor(red:0.933, green:0.459, blue:0.200, alpha: 1)
    label.numberOfLines = 0
    return label
    }()

  func configure(inout item: ListItem) {

    if let textColor = item.meta["text-color"] {
      titleLabel.textColor = UIColor(hex: textColor)
      subtitleLabel.textColor = UIColor(hex: textColor)
    }

    if titleLabel.superview == nil {
      titleLabel.text = item.title
      contentView.addSubview(titleLabel)
    }

    if subtitleLabel.superview == nil {
      subtitleLabel.text = item.subtitle
      contentView.addSubview(subtitleLabel)
    }

    layoutSubviews()
    
    item.size.height = subtitleLabel.frame.origin.y + subtitleLabel.frame.height
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    titleLabel.sizeToFit()
    titleLabel.frame.size.width = contentView.frame.width

    subtitleLabel.sizeToFit()
    var size = subtitleLabel.frame.size
    size.width -= 40
    subtitleLabel.sizeThatFits(size)
    subtitleLabel.frame.origin.y = titleLabel.frame.size.height + titleLabel.frame.origin.y
  }
}
