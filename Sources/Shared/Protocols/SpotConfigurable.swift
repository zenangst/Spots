#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

import Brick

public protocol SpotConfigurable: ItemConfigurable {

  var preferredViewSize: CGSize { get set }
}
