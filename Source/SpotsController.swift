import UIKit

public class SpotsController: UIViewController {

  private let spots: [Spotable]
  static let reuseIdentifier = "ComponentCell"
  static let minimumLineSpacing: CGFloat = 1

  lazy var layout: UICollectionViewLayout = {
    let layout = UICollectionViewFlowLayout()
    return layout
  }()

  lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: self.layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.alwaysBounceVertical = true
    collectionView.autoresizingMask = [.FlexibleRightMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleHeight, .FlexibleWidth]
    collectionView.autoresizesSubviews = true
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    collectionView.backgroundColor = UIColor.whiteColor()

    return collectionView
  }()

  public required init(spots: [Spotable]) {
    self.spots = spots
    super.init(nibName: nil, bundle: nil)
    self.view.addSubview(collectionView)
    self.view.autoresizingMask = [.FlexibleRightMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleHeight, .FlexibleWidth]
    self.view.autoresizesSubviews = true
  }

  public required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    for spot in spots { spot.layout(size) }
    layout.invalidateLayout()
  }
}

extension SpotsController: UICollectionViewDataSource {

  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return spots.count
  }

  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SpotsController.reuseIdentifier, forIndexPath: indexPath)
    let spot = spots[indexPath.item]

    spot.render().removeFromSuperview()
    spot.sizeDelegate = self
    cell.contentView.addSubview(spot.render())

    return cell
  }
}

extension SpotsController: UICollectionViewDelegateFlowLayout {

  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let spot = spots[indexPath.item]
    var frame = spot.render().frame
    frame.size.width = UIScreen.mainScreen().bounds.width
    frame.size.width -= SpotsController.minimumLineSpacing * 2
    return frame.size
  }

  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    return SpotsController.minimumLineSpacing
  }
}

extension SpotsController: SpotSizeDelegate {

  public func sizeDidUpdate() {
    collectionView.collectionViewLayout.invalidateLayout()
  }
}
