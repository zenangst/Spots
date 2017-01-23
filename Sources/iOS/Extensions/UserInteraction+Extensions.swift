import UIKit

extension UserInteraction {

  public func configure(spot: Gridable) {
    #if os(iOS)
      spot.collectionView.isPagingEnabled = paginate == .byPage
    #endif
  }
}
