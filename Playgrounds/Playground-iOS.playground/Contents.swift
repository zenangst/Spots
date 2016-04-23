//: Playground - noun: a place where people can play

import UIKit
import Spots
import Brick
import XCPlayground

enum Cell: String, StringConvertible {
  case List, Featured

  var string: String {
    return rawValue
  }
}

public class ListCell: UITableViewCell, SpotConfigurable {

  public var size = CGSize(width: 0, height: 60)
  public var item: ViewModel?

  lazy var selectedView = UIView().then {
    $0.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.4)
  }

  public override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
    selectedBackgroundView = selectedView
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configure(inout item: ViewModel) {
    backgroundColor = UIColor.whiteColor()
    textLabel?.textColor = UIColor.blackColor()
    detailTextLabel?.textColor = UIColor.blackColor()

    if let action = item.action where action.isPresent {
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

    textLabel?.x = 16
    detailTextLabel?.x = 16
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

  public func configure(component: Component) {
    backgroundColor = UIColor.whiteColor()

    label.attributedText = NSAttributedString(string: component.title.uppercaseString,
                                              attributes: [NSParagraphStyleAttributeName : paddedStyle])
  }
}

class GridTopicCell: UICollectionViewCell, SpotConfigurable {

  var size = CGSize(width: 125, height: 160)

  lazy var label = UILabel().then {
    $0.font = UIFont.boldSystemFontOfSize(11)
    $0.numberOfLines = 2
    $0.textAlignment = .Center
  }

  lazy var imageView = UIImageView().then {
    $0.contentMode = .ScaleAspectFill
  }

  lazy var blurView = UIVisualEffectView().then {
    $0.effect = UIBlurEffect(style: .ExtraLight)
  }

  lazy var paddedStyle = NSMutableParagraphStyle().then {
    $0.alignment = .Center
  }

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

  func configure(inout item: ViewModel) {
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
CarouselSpot.views[Cell.Featured] = GridTopicCell.self
GridSpot.views[Cell.Featured] = GridTopicCell.self
GridSpot.views[Cell.Featured] = GridTopicCell.self
ListSpot.headers["list"] = ListHeaderView.self
ListSpot.defaultView = ListCell.self

// Configure spots controller
SpotsController.configure = {
  $0.backgroundColor = UIColor.whiteColor()
}

CarouselSpot.configure = {
  $0.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
}

// Configure List spots
ListSpot.configure = { tableView in
  tableView.tableFooterView = UIView(frame: CGRect.zero)
}

let carouselItems = Component(items: [
  ViewModel(title: "UX", kind: Cell.Featured, meta: ["color" : UIColor.blackColor()]),
  ViewModel(title: "Persistency", kind: Cell.Featured, meta: ["color" : UIColor.grayColor()]),
  ViewModel(title: "Networking", kind: Cell.Featured, meta: ["color" : UIColor.greenColor()]),
  ViewModel(title: "Navigation", kind: Cell.Featured, meta: ["color" : UIColor.redColor()])
  ])

let listItems = Component(title: "List Spot", items: [
  ViewModel(title: "Vadym Markov", subtitle: "iOS Developer", action: "1"),
  ViewModel(title: "Ramon Gilabert Llop", subtitle: "iOS Developer", action: "2"),
  ViewModel(title: "Khoa Pham", subtitle: "iOS Developer", action: "3"),
  ViewModel(title: "Christoffer Winterkvist", subtitle: "iOS Developer", action: "4")
  ], meta: ["headerHeight" : 44])

let featuredOpensource = Component(span: 4, items: [
  ViewModel(title: "Whisper", kind: Cell.Featured, meta: ["color" : UIColor.blueColor()]),
  ViewModel(title: "Sync", kind: Cell.Featured, meta: ["color" : UIColor.orangeColor()]),
  ViewModel(title: "Presentation", kind: Cell.Featured, meta: ["color" : UIColor.yellowColor()]),
  ViewModel(title: "HUE", kind: Cell.Featured, meta: ["color" : UIColor.redColor()]),
  ])

let gridItems = Component(span: 6, items: [
  ViewModel(title: "ImagePicker", kind: Cell.Featured, meta: ["color" : UIColor.darkGrayColor()]),
  ViewModel(title: "Sugar", kind: Cell.Featured, meta: ["color" : UIColor.redColor()]),
  ViewModel(title: "Cache", kind: Cell.Featured, meta: ["color" : UIColor.greenColor()]),
  ViewModel(title: "Spots", kind: Cell.Featured, meta: ["color" : UIColor.blackColor()]),
  ViewModel(title: "Compass", kind: Cell.Featured, meta: ["color" : UIColor.blueColor()]),
  ViewModel(title: "Pages", kind: Cell.Featured, meta: ["color" : UIColor.redColor()])
  ])

let controller = SpotsController(spots: [
  ListSpot(component: Component(title: "Carousel Spot", meta: ["headerHeight" : 44])),
  CarouselSpot(carouselItems, top: 5, left: 0, bottom: 5, right: 0, itemSpacing: 0),
  ListSpot(component: Component(title: "Grid Spot", meta: ["headerHeight" : 44])),
  GridSpot(featuredOpensource, top: 10, left: 10, bottom: 20, right: 10, itemSpacing: -5),
  ListSpot(component: listItems),
  ListSpot(component: Component(title: "Grid Spot", meta: ["headerHeight" : 44])),
  GridSpot(gridItems, top: 10, left: 10, bottom: 20, right: 10, itemSpacing: -5),
  ]
)

XCPlaygroundPage.currentPage.liveView = controller.view
