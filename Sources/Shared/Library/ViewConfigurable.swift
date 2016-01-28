#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

public protocol ViewConfigurable: class {
  var size: CGSize { get set }

  func configure(inout item: ViewModel)
}
