import UIKit

public protocol Itemble: class {
  var size: CGSize { get set }

  func configure(inout item: ListItem)
}
