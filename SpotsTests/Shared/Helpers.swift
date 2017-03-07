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

extension Controller {

  func prepareController() {
    preloadView()
    viewDidAppear()
    spots.forEach {
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
  func viewDidAppear() {
    viewWillAppear(true)
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
  class HeaderView: UIView, ItemConfigurable, Componentable {

    public var preferredHeaderHeight: CGFloat = 50.0

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

    func configure(_ item: inout ContentModel) {
      titleLabel.text = item.title
    }

    func configure(_ component: ComponentModel) {
      titleLabel.text = component.title
    }
  }

  class FooterView: UIView, ItemConfigurable, Componentable {

    var preferredHeaderHeight: CGFloat = 50

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

    func configure(_ item: inout ContentModel) {
      titleLabel.text = item.title
    }

    func configure(_ component: ComponentModel) {
      titleLabel.text = "This is a footer"
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

    func configure(_ item: inout ContentModel) {
      titleLabel.text = item.title
    }
  }

  class CustomListCell: UITableViewCell, ItemConfigurable {

    var preferredViewSize: CGSize = CGSize(width: 0, height: 44)

    func configure(_ item: inout ContentModel) {
      textLabel?.text = item.text
    }
  }

  class CustomListHeaderView: UITableViewHeaderFooterView, Componentable {
    var preferredHeaderHeight: CGFloat = 88

    func configure(_ component: ComponentModel) {
      textLabel?.text = component.title
    }
  }

  class CustomGridCell: UICollectionViewCell, ItemConfigurable {

    var preferredViewSize: CGSize = CGSize(width: 0, height: 44)

    func configure(_ item: inout ContentModel) {}
  }

  class CustomGridHeaderView: UICollectionReusableView, Componentable {

    var preferredHeaderHeight: CGFloat = 88

    lazy var textLabel = UILabel()

    func configure(_ component: ComponentModel) {
      textLabel.text = component.title
    }
  }
#endif

class TestView: View, ItemConfigurable {
  var preferredViewSize: CGSize = CGSize(width: 50, height: 50)

  func configure(_ item: inout ContentModel) {

  }
}
