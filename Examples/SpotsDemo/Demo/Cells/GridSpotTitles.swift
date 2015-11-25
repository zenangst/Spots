import UIKit
import GoldenRetriever
import Sugar
import Spots

class GridSpotCellTitles : UICollectionViewCell, Itemble {

  var size = CGSize(width: 88, height: 88)

  lazy var titleLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: self.contentView.frame)
    label.textColor = UIColor.blackColor()
    label.textAlignment = .Center
    label.autoresizingMask = [.FlexibleWidth]
    label.font = UIFont(name: "AvenirNext-Bold", size: 30)
    label.numberOfLines = 2
    return label
    }()

  lazy var subtitleLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: self.contentView.frame)
    label.textAlignment = .Justified
    label.font = UIFont.systemFontOfSize(16)
    label.textColor = UIColor(red:0.933, green:0.459, blue:0.200, alpha: 1)
    label.font = UIFont(name: "Georgia", size: 16)
    label.numberOfLines = 0
    return label
    }()

  lazy var metaText: UILabel = { [unowned self] in
    let label = UILabel(frame: self.contentView.frame)
    label.textAlignment = .Justified
    label.font = UIFont.systemFontOfSize(14)
    label.numberOfLines = 0
    return label
  }()

  lazy var paddedStyle: NSParagraphStyle = {
    let style = NSMutableParagraphStyle()
    style.alignment = .Left
    style.firstLineHeadIndent = 20.0
    style.headIndent = 20.0
    style.tailIndent = -20.0
    return style
    }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    [titleLabel, subtitleLabel, metaText].forEach { contentView.addSubview($0) }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(inout item: ListItem) {
    optimize()
    if let textColor = item.meta["text-color"] as? String {
      titleLabel.textColor = UIColor(hex: textColor)
    }

    titleLabel.text = item.title
    subtitleLabel.attributedText = NSAttributedString(string: item.subtitle,
      attributes: [NSParagraphStyleAttributeName : paddedStyle])
    metaText.attributedText = NSAttributedString(string: item.meta.property("text") ?? "",
      attributes: [NSParagraphStyleAttributeName : paddedStyle])
    metaText.textColor = UIColor(hex: item.meta.property("text-color") ?? "000000")

    layoutSubviews()

    item.size.height = metaText.frame.origin.y + metaText.frame.height + 20
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    [titleLabel, subtitleLabel, metaText].forEach {
      $0.sizeToFit()
      $0.frame.size.width = contentView.frame.width
    }

    titleLabel.frame.origin.y = 10
    subtitleLabel.frame.origin.y = titleLabel.frame.size.height + titleLabel.frame.origin.y + 10
    metaText.frame.origin.y = subtitleLabel.frame.size.height + subtitleLabel.frame.origin.y + 10
  }
}
