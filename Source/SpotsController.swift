import UIKit
import Sugar

public class SpotsController: UIViewController {

  public private(set) var spots: [Spotable]
  static let reuseIdentifier = "SpotReuseIdentifier"
  
  weak public var spotDelegate: SpotsDelegate?

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
    collectionView.autoresizingMask = [
      .FlexibleRightMargin,
      .FlexibleLeftMargin,
      .FlexibleBottomMargin,
      .FlexibleTopMargin,
      .FlexibleHeight,
      .FlexibleWidth
    ]
    collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.registerClass(SpotCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    return collectionView
  }()

  public lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: "refreshSpots:", forControlEvents: .ValueChanged)

    return refreshControl
    }()

  public required init(spots: [Spotable], refreshable: Bool = true) {
    self.spots = spots
    super.init(nibName: nil, bundle: nil)

    view.addSubview(collectionView)

    if refreshable {
      collectionView.addSubview(refreshControl)
    }

    view.autoresizesSubviews = true
    view.autoresizingMask = [
      .FlexibleBottomMargin,
      .FlexibleHeight,
      .FlexibleLeftMargin,
      .FlexibleRightMargin,
      .FlexibleTopMargin,
      .FlexibleWidth
    ]

    for (index, _) in spots.enumerate() {
      self.spots[index].index = index
    }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    spots.forEach { $0.layout(size) }
    layout.invalidateLayout()
  }

  public func spotAtIndex(index: Int) -> Spotable? {
    let spot = spots.filter { $0.index == index }.first
    return spot
  }

  public func reloadSpots() {
    dispatch { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.spots.forEach { $0.reload([]) {} }
    }
  }

  public func updateSpotAtIndex(index: Int, closure: (spot: Spotable) -> Spotable, completion: (() -> Void)? = nil) {
    if let spot = spotAtIndex(index) {
      spots[spot.index] = closure(spot: spot)

      dispatch { [weak self] in
        guard let weakSelf = self else { return }

        weakSelf.spots[spot.index].reload([index]) {
          weakSelf.collectionView.performBatchUpdates({
            weakSelf.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
            }, completion: { _ in
              weakSelf.collectionView.collectionViewLayout.invalidateLayout()
              completion?()
          })
        }
      }
    }
  }

  public func append(item: ListItem, spotIndex: Int, completion: (() -> Void)? = nil) {
    guard let spot = spotAtIndex(spotIndex) else { return }
    spot.append(item) { completion?() }
  }
  
  public func append(items: [ListItem], spotIndex: Int, completion: (() -> Void)? = nil) {
    guard let spot = spotAtIndex(spotIndex) else { return }
    spot.append(items) { completion?() }
  }

  public func insert(item: ListItem, index: Int, spotIndex: Int, completion: (() -> Void)? = nil) {
    guard let spot = spotAtIndex(spotIndex) else { return }
    spot.insert(item, index: index)  { completion?() }
  }

  public func update(item: ListItem, index: Int, spotIndex: Int, completion: (() -> Void)? = nil) {
    guard let spot = spotAtIndex(spotIndex) else { return }
    spot.update(item, index: index)  { completion?() }
  }

  public func delete(index: Int, spotIndex: Int, completion: (() -> Void)? = nil) {
    guard let spot = spotAtIndex(spotIndex) else { return }
    spot.delete(index) { completion?() }
  }

  public func delete(indexes indexes: [Int], spotIndex: Int, completion: (() -> Void)? = nil) {
    guard let spot = spotAtIndex(spotIndex) else { return }
    spot.delete(indexes) { completion?() }
  }

  public func refreshSpots(refreshControl: UIRefreshControl) {
    dispatch { [weak self] in
      if let weakSelf = self, spotDelegate = weakSelf.spotDelegate {
        spotDelegate.spotsDidReload(refreshControl)
      } else {
        delay(0.5) { [weak self] in
          self?.refreshControl.endRefreshing()
        }
      }
    }
  }
}

extension SpotsController: UICollectionViewDataSource {

  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return spots.count
  }

  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SpotsController.reuseIdentifier, forIndexPath: indexPath)

    if let spotCell = cell as? SpotCell {
      spotCell.spotView = spots[indexPath.item].render()
    }

    cell.optimize()
    spots[indexPath.item].sizeDelegate = self
    spots[indexPath.item].spotDelegate = spotDelegate

    return cell
  }
}

extension SpotsController: UICollectionViewDelegateFlowLayout {

  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    var component = spots[indexPath.item].component
    if component.size == nil {
      spots[indexPath.item].setup()
      component.size = CGSize(
        width: UIScreen.mainScreen().bounds.width,
        height: spots[indexPath.item].render().frame.height)
    }

    return component.size!
  }
}

extension SpotsController: SpotSizeDelegate {

  public func sizeDidUpdate() {
    collectionView.collectionViewLayout.invalidateLayout()
  }

  public func scrollToPreviousCell(component: Component) {
    for (index, spot) in spots.enumerate() {
      if spot.component == component {
        UIView.animateWithDuration(0.5, delay: 0.0, options: [.AllowUserInteraction, .BeginFromCurrentState], animations: {
          let prevIndex = index - 1
          if prevIndex >= 0 {
            self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: prevIndex, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: false)
          }
        }, completion: nil)
        break
      }
    }
  }

  public func scrollToNextCell(component: Component) {
    for (index, spot) in spots.enumerate() {
      if spot.component == component {
        UIView.animateWithDuration(0.5, delay: 0.0, options: [.AllowUserInteraction, .BeginFromCurrentState], animations: {
          let nextIndex = index + 1
          if nextIndex < self.spots.count {
            self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: nextIndex, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: false)
          }
          }, completion: nil)
        break
      }
    }
  }
}
