#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

import Brick

public protocol SpotConfigurable: ViewConfigurable {

  var size: CGSize { get set }
}
