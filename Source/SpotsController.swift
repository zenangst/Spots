import UIKit

public class SpotsController: UIViewController {

  private let spots: [Spotable]
  static let reuseIdentifier = "ComponentCell"

  lazy var layout: UICollectionViewLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.sectionInset = UIEdgeInsetsZero
    return layout
  }()

  lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: self.layout)

    collectionView.alwaysBounceVertical = true
    collectionView.autoresizesSubviews = true
    collectionView.autoresizingMask = [.FlexibleRightMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleHeight, .FlexibleWidth]
    collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    return collectionView
  }()

  public required init(spots: [Spotable]) {
    self.spots = spots
    super.init(nibName: nil, bundle: nil)
    self.view.addSubview(collectionView)
    self.view.autoresizesSubviews = true
    self.view.autoresizingMask = [.FlexibleRightMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleHeight, .FlexibleWidth]
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    spots.forEach { $0.layout(size) }
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

    cell.contentView.subviews.forEach { $0.removeFromSuperview() }
    cell.contentView.addSubview(spot.render())
    spot.sizeDelegate = self

    return cell
  }
}

extension SpotsController: UICollectionViewDelegateFlowLayout {

  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    var frame = spots[indexPath.item].render().frame
    frame.size.width = UIScreen.mainScreen().bounds.width
    return frame.size
  }
}

extension SpotsController: SpotSizeDelegate {

  public func sizeDidUpdate() {
    collectionView.collectionViewLayout.invalidateLayout()
  }
}
