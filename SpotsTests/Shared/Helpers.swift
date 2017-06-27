@testable import Spots
#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

import Tailor

struct Meta {
  var id = 0
  var name: String?
}

extension Meta: Mappable {

  init(_ map: [String : Any]) {
    id = map.property("id") ?? 0
    name = map.property("name") ?? ""
  }
}

extension SpotsController {

  func prepareController() {
    preloadView()
    viewWillAppear()
    viewDidAppear()
    components.forEach {
      $0.view.layoutSubviews()
    }
  }

  func preloadView() {
    let _ = view
    #if os(OSX)
      view.frame.size = CGSize(width: 100, height: 100)
    #endif
  }
  #if !os(OSX)

  func viewWillAppear() {
    viewWillAppear(true)
  }

  func viewDidAppear() {
    viewDidAppear(true)
  }
  #endif

  func scrollTo(_ point: CGPoint) {
    #if !os(OSX)
      scrollView.setContentOffset(point, animated: false)
      scrollView.layoutSubviews()
    #endif
  }
}

#if !os(OSX)

  class RegularView: UIView {
    override init(frame: CGRect) {
      var frame = frame
      frame.size.height = 44
      super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }

  class ItemConfigurableView: UIView, ItemConfigurable {

    override init(frame: CGRect) {
      super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: Item) {
      frame.size.height = 75
    }

    func computeSize(for item: Item, containerSize: CGSize) -> CGSize {
      return CGSize(width: 200, height: 50)
    }
  }

  class HeaderView: UIView, ItemConfigurable {

    var preferredViewSize: CGSize = CGSize(width: 200, height: 50)

    lazy var titleLabel: UILabel = {
      let label = UILabel()
      label.textAlignment = .center
      return label
    }()

    override init(frame: CGRect) {
      super.init(frame: frame)
      addSubview(titleLabel)

      configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func configureConstraints() {
      titleLabel.translatesAutoresizingMaskIntoConstraints = false
      titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
      titleLabel.leftAnchor.constraint(equalTo: titleLabel.superview!.leftAnchor).isActive = true
      titleLabel.rightAnchor.constraint(equalTo: titleLabel.superview!.rightAnchor).isActive = true
      titleLabel.centerYAnchor.constraint(equalTo: titleLabel.superview!.centerYAnchor).isActive = true
    }

    func configure(with item: Item) {
      titleLabel.text = item.title
    }

    func computeSize(for item: Item, containerSize: CGSize) -> CGSize {
      return CGSize(width: 200, height: 50)
    }
  }

  class FooterView: UIView, ItemConfigurable {

    var preferredViewSize: CGSize = CGSize(width: 200, height: 50)

    lazy var titleLabel: UILabel = {
      let label = UILabel()
      label.textAlignment = .center
      return label
    }()

    override init(frame: CGRect) {
      super.init(frame: frame)
      addSubview(titleLabel)

      configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func configureConstraints() {
      titleLabel.translatesAutoresizingMaskIntoConstraints = false
      titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
      titleLabel.leftAnchor.constraint(equalTo: titleLabel.superview!.leftAnchor).isActive = true
      titleLabel.rightAnchor.constraint(equalTo: titleLabel.superview!.rightAnchor).isActive = true
      titleLabel.centerYAnchor.constraint(equalTo: titleLabel.superview!.centerYAnchor).isActive = true
    }

    func configure(with item: Item) {
      titleLabel.text = item.title
    }

    func computeSize(for item: Item, containerSize: CGSize) -> CGSize {
      return CGSize(width: 200, height: 50)
    }
  }

  class TextView: UIView, ItemConfigurable {

    var preferredViewSize: CGSize = CGSize(width: 200, height: 50)

    lazy var titleLabel: UILabel = {
      let label = UILabel()
      label.textAlignment = .center
      return label
    }()

    override init(frame: CGRect) {
      super.init(frame: frame)
      addSubview(titleLabel)

      backgroundColor = UIColor.gray.withAlphaComponent(0.25)

      configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func configureConstraints() {
      titleLabel.translatesAutoresizingMaskIntoConstraints = false
      titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
      titleLabel.leftAnchor.constraint(equalTo: titleLabel.superview!.leftAnchor).isActive = true
      titleLabel.rightAnchor.constraint(equalTo: titleLabel.superview!.rightAnchor).isActive = true
      titleLabel.centerYAnchor.constraint(equalTo: titleLabel.superview!.centerYAnchor).isActive = true
    }

    func configure(with item: Item) {
      titleLabel.text = item.title
    }

    func computeSize(for item: Item, containerSize: CGSize) -> CGSize {
      return CGSize(width: 200, height: 50)
    }
  }

  class CustomListCell: UITableViewCell, ItemConfigurable {
    func configure(with item: Item) {
      textLabel?.text = item.text
    }

    func computeSize(for item: Item, containerSize: CGSize) -> CGSize {
      return CGSize(width: 50, height: 44)
    }
  }

  class CustomListHeaderView: UITableViewHeaderFooterView, ItemConfigurable {
    func configure(with item: Item) {
      textLabel?.text = item.title
    }

    func computeSize(for item: Item, containerSize: CGSize) -> CGSize {
      return CGSize(width: 0, height: 88)
    }
  }

  class CustomGridCell: UICollectionViewCell, ItemConfigurable {

    func configure(with item: Item) {}
    
    func computeSize(for item: Item, containerSize: CGSize) -> CGSize {
      return CGSize(width: 50, height: 44)
    }
  }

  class CustomGridHeaderView: UICollectionReusableView, ItemConfigurable {
    lazy var textLabel = UILabel()

    func computeSize(for item: Item, containerSize: CGSize) -> CGSize {
      return CGSize(width: 0, height: 88)
    }

    func configure(with item: Item) {
      textLabel.text = item.title
    }
  }
#endif

class TestView: View, ItemConfigurable {
  var item: Item?
  
  func configure(with item: Item) {
    self.item = item
  }

  func computeSize(for item: Item, containerSize: CGSize) -> CGSize {
    return CGSize(width: 50, height: 50)
  }
}
