//: Playground - noun: a place where people can play

import UIKit
import Spots
import XCPlayground

enum Cell: String, StringConvertible {
  case List, Featured

  var string: String {
    return rawValue
  }
}

public class ListCell: UITableViewCell, ItemConfigurable {

  public var preferredViewSize: CGSize(width: 0, height: 60)
  public var item: Item?

  lazy var selectedView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.darkGray.colorWithAlphaComponent(0.4)

    return view
  }()

  public override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
    selectedBackgroundView = selectedView
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(inout item: Item) {
    backgroundColor = UIColor.whiteColor()
    textLabel?.textColor = UIColor.blackColor()
    detailTextLabel?.textColor = UIColor.blackColor()

    if let action = item.action where !action.isEmpty {
      accessoryType = .DisclosureIndicator
    } else {
      accessoryType = .None
    }

    detailTextLabel?.text = item.subtitle
    textLabel?.text = item.title

    item.size.height = item.size.height > 0.0 ? item.size.height : size.height
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    textLabel?.frame.origin.x = 16
    detailTextLabel?.frame.origin.x = 16
  }
}

public class ListHeaderView: UIView, Componentable {

  public var defaultHeight: CGFloat = 44

  lazy var label: UILabel = { [unowned self] in
    let label = UILabel(frame: self.frame)
    label.font = UIFont.boldSystemFontOfSize(11)

    return label
    }()

  lazy var paddedStyle: NSParagraphStyle = {
    let style = NSMutableParagraphStyle()
    style.alignment = .Left
    style.firstLineHeadIndent = 15.0
    style.headIndent = 15.0
    style.tailIndent = -15.0

    return style
  }()

  public override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(label)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(component: ComponentModel) {
    backgroundColor = UIColor.whiteColor()

    label.attributedText = NSAttributedString(string: component.title.uppercaseString,
                                              attributes: [NSParagraphStyleAttributeName : paddedStyle])
  }
}

class GridTopicCell: UICollectionViewCell, ItemConfigurable {

  var preferredViewSize: CGSize(width: 125, height: 160)

  lazy var label: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFontOfSize(11)
    label.numberOfLines = 2
    label.textAlignment = .Center

    return label
  }()

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFill

    return imageView
  }()

  lazy var blurView: UIVisualEffectView = {
    let blurView = UIVisualEffectView()
    blurView.effect = UIBlurEffect(style: .ExtraLight)

    return blurView
  }()

  lazy var paddedStyle: NSMutableParagraphStyle = {
    let paddedStyle = NSMutableParagraphStyle()
    paddedStyle.alignment = .Center

    return paddedStyle
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.clipsToBounds = true
    contentView.layer.cornerRadius = 3

    blurView.contentView.addSubview(label)

    [imageView, blurView].forEach { contentView.addSubview($0) }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(inout item: Item) {
    contentView.backgroundColor = item.meta("color", UIColor.whiteColor()).colorWithAlphaComponent(0.4)

    blurView.width = contentView.width
    blurView.height = 48
    blurView.y = 120

    label.attributedText = NSAttributedString(string: item.title,
                                              attributes: [NSParagraphStyleAttributeName : paddedStyle])
    label.sizeToFit()
    label.height = 38
    label.width = blurView.frame.width

    if item.size.height == 0.0 {
      item.size.height = 160
    }
  }
}

// Register spots
CarouselSpot.register(view: GridTopicCell.self, identifier: Cell.Featured)
GridSpot.register(view: GridTopicCell.self, identifier: Cell.Featured)
ListSpot.register(header: ListHeaderView.self, identifier: "list")
ListSpot.register(defaultView: ListCell.self)

// Configure spots controller
Controller.configure = {
  $0.backgroundColor = UIColor.whiteColor()
}

CarouselSpot.configure = { collectionView, layout in
  collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
}

// Configure List spots
ListSpot.configure = { tableView in
  tableView.tableFooterView = UIView(frame: CGRect.zero)
}

let carouselItems = ComponentModel(items: [
  Item(title: "UX", kind: Cell.Featured, meta: ["color" : UIColor.blackColor()]),
  Item(title: "Persistency", kind: Cell.Featured, meta: ["color" : UIColor.grayColor()]),
  Item(title: "Networking", kind: Cell.Featured, meta: ["color" : UIColor.greenColor()]),
  Item(title: "Navigation", kind: Cell.Featured, meta: ["color" : UIColor.redColor()])
  ])

let listItems = ComponentModel(title: "List Spot", items: [
  Item(title: "Vadym Markov", subtitle: "iOS Developer", action: "1"),
  Item(title: "Ramon Gilabert Llop", subtitle: "iOS Developer", action: "2"),
  Item(title: "Khoa Pham", subtitle: "iOS Developer", action: "3"),
  Item(title: "Christoffer Winterkvist", subtitle: "iOS Developer", action: "4")
  ], meta: ["headerHeight" : 44])

let featuredOpensource = ComponentModel(span: 4, items: [
  Item(title: "Whisper", kind: Cell.Featured, meta: ["color" : UIColor.blueColor()]),
  Item(title: "Sync", kind: Cell.Featured, meta: ["color" : UIColor.orangeColor()]),
  Item(title: "Presentation", kind: Cell.Featured, meta: ["color" : UIColor.yellowColor()]),
  Item(title: "HUE", kind: Cell.Featured, meta: ["color" : UIColor.redColor()]),
  ])

let gridItems = ComponentModel(span: 6, items: [
  Item(title: "ImagePicker", kind: Cell.Featured, meta: ["color" : UIColor.darkGrayColor()]),
  Item(title: "Sugar", kind: Cell.Featured, meta: ["color" : UIColor.redColor()]),
  Item(title: "Cache", kind: Cell.Featured, meta: ["color" : UIColor.greenColor()]),
  Item(title: "Spots", kind: Cell.Featured, meta: ["color" : UIColor.blackColor()]),
  Item(title: "Compass", kind: Cell.Featured, meta: ["color" : UIColor.blueColor()]),
  Item(title: "Pages", kind: Cell.Featured, meta: ["color" : UIColor.redColor()])
  ])

let controller = Controller(spots: [
  ListSpot(component: ComponentModel(title: "Carousel Spot", meta: ["headerHeight" : 44])),
  CarouselSpot(carouselItems, top: 5, left: 0, bottom: 5, right: 0, itemSpacing: 0),
  ListSpot(component: ComponentModel(title: "Grid Spot", meta: ["headerHeight" : 44])),
  GridSpot(featuredOpensource, top: 10, left: 10, bottom: 20, right: 10, itemSpacing: -5),
  ListSpot(component: listItems),
  ListSpot(component: ComponentModel(title: "Grid Spot", meta: ["headerHeight" : 44])),
  GridSpot(gridItems, top: 10, left: 10, bottom: 20, right: 10, itemSpacing: -5),
  ]
)

XCPlaygroun