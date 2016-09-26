import UIKit
import Brick

public protocol SpotComposable: class {
  var contentView: View { get }

  func configure(inout item: Item, spots: [Spotable]?)
  func parse(item: Item) -> [Spotable]
}
