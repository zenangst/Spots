import UIKit

protocol Gridable {
  var size: CGSize { get set }

  func configure(item: ListItem)
}
