import UIKit
import Imaginary
import Sugar
import Spots
import Hue
import Brick

class GridSpotCellTitles : UICollectionViewCell, SpotConfigurable {

  var preferredViewSize = CGSize(width: 88, height: 88)

  lazy var titleLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: self.contentView.frame)
    label.textColor = UIColor.black
    label.textAlignment = .center
    label.autoresizingMask = [.flexibleWidth]
    label.font = UIFont(name: "AvenirNext-Bold", size: 30)
    label.numberOfLines = 2
    return label
    }()

  lazy var subtitleLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: self.contentView.frame)
    label.textAlignment = .justified
    label.font = UIFont.systemFont(ofSize: 16)
    label.textColor = UIColor(red:0.933, green:0.459, blue:0.200, alpha: 1)
    label.font = UIFont(name: "Georgia", size: 16)
    label.numberOfLines = 0
    return label
    }()

  lazy var metaText: UILabel = { [unowned self] in
    let label = UILabel(frame: self.contentView.frame)
    label.textAlignment = .justified
    label.font = UIFont.systemFont(ofSize: 14)
    label.numberOfLines = 0
    return label
  }()

  lazy var paddedStyle: NSParagraphStyle = {
    let style = NSMutableParagraphStyle()
    style.alignment = .left
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

  func configure( _ item: inout Item) {
    optimize()
    if let textColor = item.meta["text-color"] as? String {
      titleLabel.textColor = UIColor(hex: textColor)
    }

    titleLabel.text = item.title
    subtitleLabel.attributedText = NSAttributedString(string: item.subtitle,
      attributes: [NSParagraphStyleAttributeName : paddedStyle])
    metaText.attributedText = NSAttributedString(string: item.text,
      attributes: [NSParagraphStyleAttributeName : paddedStyle])
    metaText.textColor = UIColor(hex: item.meta.property("text-color") ?? "000000")

    [titleLabel, subtitleLabel, metaText].forEach {
      $0.frame.size.width = contentView.frame.width
      $0.sizeToFit()
      $0.frame.size.width = contentView.frame.width
    }

    subtitleLabel.frame.origin.y = titleLabel.frame.maxY
    metaText.frame.origin.y = subtitleLabel.frame.maxY

    item.size.height = metaText.frame.maxY + 20
    item.size.width = UIScreen.main.bounds.width
  }
}
