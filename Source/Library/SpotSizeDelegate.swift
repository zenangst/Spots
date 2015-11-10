import UIKit

public protocol SpotSizeDelegate: class {
  func sizeDidUpdate()
  func contentOffset() -> CGPoint
}
