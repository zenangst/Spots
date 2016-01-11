#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

public protocol Itemble: class {
  var size: CGSize { get set }

  func configure(inout item: ListItem)
}
