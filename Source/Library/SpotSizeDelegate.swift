import UIKit

public protocol SpotSizeDelegate: class {
  func sizeDidUpdate()
  func scrollToPreviousCell(component: Component)
  func scrollToNextCell(component: Component)
}
