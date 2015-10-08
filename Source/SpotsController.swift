import UIKit

class SpotsController: UIViewController {

  private let spots: [Spotable]
  static let reuseIdentifier = "ComponentCell"

  lazy var collectionView: UICollectionView = { [unowned self] in
    let layout = UICollectionViewFlowLayout()
    let collectionView = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.alwaysBounceVertical = true
    collectionView.autoresizingMask = [.FlexibleRightMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleHeight, .FlexibleWidth]
    collectionView.autoresizesSubviews = true
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    collectionView.backgroundColor = UIColor.whiteColor()

    return collectionView
  }()

  required init(spots: [Spotable]) {
    self.spots = spots
    super.init(nibName: nil, bundle: nil)
    self.view.addSubview(collectionView)
    self.view.autoresizingMask = [.FlexibleRightMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleHeight, .FlexibleWidth]
    self.view.autoresizesSubviews = true
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}

extension SpotsController: UICollectionViewDataSource {

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return spots.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let spot = spots[indexPath.item]
    spot.sizeDelegate = self

    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SpotsController.reuseIdentifier, forIndexPath: indexPath)
    cell.contentView.addSubview(spot.render())
    
    return cell
  }
}

extension SpotsController: UICollectionViewDelegateFlowLayout {

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let spot = spots[indexPath.item]
    return spot.render().frame.size
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 1
  }
}

extension SpotsController: SpotSizeDelegate {

  func sizeDidUpdate() {
    collectionView.collectionViewLayout.invalidateLayout()
  }
}
