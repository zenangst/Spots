import Foundation
import UIKit
import Spots

open class MainViewController: Controller {

    convenience init(title: String, spots: [Spotable]) {
        self.init(spots: spots)
        self.title = title
    }
}
