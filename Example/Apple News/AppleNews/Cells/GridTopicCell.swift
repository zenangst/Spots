import UIKit
import GoldenRetriever
import Sugar

class GridTopicCell: UICollectionViewCell, Itemble {

  var size = CGSize(width: 125, height: 160)
  
  lazy var label: UILabel = { [unowned self] in
    let label = UILabel(frame: CGRectZero)
    label.font = UIFont.systemFontOfSize(11)
    label.numberOfLines = 4
    label.textAlignment = .Center
    label.autoresizingMask = [.FlexibleWidth]
    return label
    }()

  lazy var paddedStyle: NSParagraphStyle = {
    let style = NSMutableParagraphStyle()
    style.alignment = .Center
    return style
    }()

  func configure(inout item: ListItem) {
    contentView.backgroundColor = UIColor.grayColor()
    contentView.layer.cornerRadius = 3

    if label.superview == nil {
      contentView.addSubview(label)
    }
    
    label.attributedText = NSAttributedString(string: item.title,
      attributes: [NSParagraphStyleAttributeName : paddedStyle])
    label.frame.size.height = 88
    label.frame.size.width = size.width
  }
}
