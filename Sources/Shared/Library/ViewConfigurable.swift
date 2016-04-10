#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

import Brick

public protocol ViewConfigurable: class {
  var size: CGSize { get set }

  func configure(inout item: ViewModel)
}
