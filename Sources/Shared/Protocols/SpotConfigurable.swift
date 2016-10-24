#if os(OSX)
  import Foundation
#else
  import UIKit
#endif

import Brick

/// A protocol for views that will be used inside of Spotable objects.
public protocol SpotConfigurable: ItemConfigurable {

  /// The perferred view size of the view.
  var preferredViewSize: CGSize { get }

  func prepareForReuse()
}
