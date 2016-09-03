import UIKit
import Brick

public protocol SpotComposable: class {
  var contentView: View { get }

  func configure(inout item: ViewModel, spots: [Spotable]?)
  func parse(item: ViewModel) -> [Spotable]
}
