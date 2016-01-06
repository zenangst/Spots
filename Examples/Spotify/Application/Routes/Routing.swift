import UIKit

public protocol Routing {
  func navigate(url: NSURL, navigationController: UINavigationController) -> Bool
}
