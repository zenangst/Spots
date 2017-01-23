import Foundation

/// A dispatch enum
///
/// - main:        DispatchQueue.main
/// - interactive: DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
/// - initiated:   DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
/// - utility:     DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
/// - background:  DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
/// - custom:      A user defined queue
enum SpotDispatchQueue {
  case main, interactive, initiated, utility, background, custom(DispatchQueue)
}
