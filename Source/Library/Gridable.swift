import UIKit

protocol Gridable: class {
  var size: CGSize { get set }

  func configure(item: ListItem)
}
