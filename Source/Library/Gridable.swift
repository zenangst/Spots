import UIKit

protocol Itemble: class {
  var size: CGSize { get set }

  func configure(inout item: ListItem)
}
