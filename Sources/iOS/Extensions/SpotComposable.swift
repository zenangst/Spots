import UIKit
import Brick

public protocol SpotComposable: class {
  var contentView: View { get }

  func configure(inout item: ViewModel, spots: [Spotable]?)
  func parse(item: ViewModel) -> [Spotable]
}

public extension SpotComposable where Self : View {

  func configure(inout item: ViewModel, spots: [Spotable]?) {
    guard let spots = spots else { return }

    var height: CGFloat = 0.0

    spots.enumerate().forEach { index, spot in
      spot.component.size = CGSize(
        width: contentView.frame.width,
        height: ceil(spot.render().height))

      spot.component.size?.height == Optional(0.0)
        ? spot.setup(contentView.frame.size)
        : spot.layout(contentView.frame.size)

      contentView.addSubview(spot.render())
      spot.render().frame.origin.y = height
      spot.render().layoutIfNeeded()
      height += spot.render().contentSize.height
    }

    item.size.height = height
  }
}

public extension SpotComposable {

  public func parse(item: ViewModel) -> [Spotable] {
    let spots = Parser.parse(item.children)
    return spots
  }
}
