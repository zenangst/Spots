import UIKit

public protocol Routing {
  func navigate(_ url: URL, navigationController: UINavigationController) -> Bool
}
