import Foundation

#if os(iOS)
  import UIKit
#endif

/// A refresh delegate for handling reloading of a Spot
public protocol RefreshDelegate: class {

  /// A delegate method for when your spot controller was refreshed using pull to refresh
  ///
  /// - parameter spots: A collection of Spotable objects
  /// - parameter refreshControl: A UIRefreshControl
  /// - parameter completion: A completion closure that should be triggered when the update is completed
  #if os(iOS)
  func spotablesDidReload(_ spots: [Spotable], refreshControl: UIRefreshControl, completion: Completion)
  #endif
}
