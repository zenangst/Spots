import UIKit

extension UserInteraction {

  public func configure(spot: Gridable) {
    spot.collectionView.isPagingEnabled = paginate == .byPage
  }
}
