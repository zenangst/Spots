#if os(iOS)
  import UIKit
#else
  import Foundation
#endif

import Brick
import Cache

public protocol SpotsProtocol: class {
  /// A SpotCache object
  var stateCache: SpotCache? { get set }
  /// The internal SpotsScrollView
  var spotsScrollView: SpotsScrollView { get }
  /// A delegate that conforms to SpotsDelegate
  var spotsDelegate: SpotsDelegate? { get }
  /// A collection of Spotable objects used in composition
  var compositeSpots: [Int : [Int : [Spotable]]] { get set }
  /// A collection of Spotable objects
  var spots: [Spotable] { get set }
  /// An array of refresh position to avoid calling multiple refreshes
  var refreshPositions: [CGFloat] { get set }
  /// A view controller view
  #if os(OSX)
  var view: View { get }
  #else
  var view: View! { get }
  #endif

  var spot: Spotable? { get }

  /// A dictionary representation of the controller
  var dictionary: [String : Any] { get }

  #if os(iOS)
  var spotsRefreshDelegate: SpotsRefreshDelegate? { get set }
  #endif

  #if DEVMODE
  var fileQueue: DispatchQueue { get }
  var source: DispatchSourceFileSystemObject! { get set }
  #endif

  func setupSpots(_ animated: ((_ view: View) -> Void)?)
  func setupSpot(at index: Int, spot: Spotable)
  func spot<T>(at index: Int, _ type: T.Type) -> T?
  func resolve(spot closure: (_ index: Int, _ spot: Spotable) -> Bool) -> Spotable?

  #if os(OSX)
  init(spots: [Spotable], backgroundType: SpotsControllerBackground)
  #else
  init(spots: [Spotable])
  #endif
}
