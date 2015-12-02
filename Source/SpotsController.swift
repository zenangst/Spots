import UIKit
import Sugar

public class SpotsController: UIViewController {

  public private(set) var spots: [Spotable]
  static let reuseIdentifier = "SpotReuseIdentifier"
  
  weak public var spotDelegate: SpotsDelegate?

  public lazy var layout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.sectionInset = UIEdgeInsetsZero
    return layout
  }()

  public lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: self.layout)

    collectionView.alwaysBounceVertical = true
    collectionView.autoresizesSubviews = true
    collectionView.autoresizingMask = [
      .FlexibleBottomMargin,
      .FlexibleHeight,
      .FlexibleLeftMargin,
      .FlexibleRightMargin,
      .FlexibleTopMargin,
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

  public required init(spots: [Spotable] = [], refreshable: Bool = true) {
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

    spots.enumerate().forEach { spot($0.index).index = $0.index }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }

  public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    spots.forEach { $0.layout(size) }
    layout.invalidateLayout()
  }

  public func spotAtIndex(index: Int) -> Spotable? {
    return spots.filter{ $0.index == index }.first
  }

  public func spot(closure: (index: Int, spot: Spotable) -> Bool) -> Spotable? {
    for (index, spot) in spots.enumerate()
      where closure(index: index, spot: spot) {
        return spot
    }
    return nil
  }

  public func filter(@noescape includeElement: (Spotable) -> Bool) -> [Spotable] {
    return spots.filter(includeElement)
  }

  public func reloadSpots() {
    dispatch { [weak self] in
      self?.spots.forEach { $0.reload([]) {} }
    }
  }

  public func updateSpotAtIndex(index: Int, closure: (spot: Spotable) -> Spotable, completion: (() -> Void)? = nil) {
    guard let spot = spotAtIndex(index) else { return }
    spots[spot.index] = closure(spot: spot)

    dispatch { [weak self] in
      guard let weakSelf = self else { return }

      weakSelf.spot(spot.index).reload([index]) {
        weakSelf.collectionView.performBatchUpdates({
          weakSelf.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
          }, completion: { _ in
            weakSelf.collectionView.collectionViewLayout.invalidateLayout()
            completion?()
        })
      }
    }
  }

  public func append(item: ListItem, spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.append(item) { completion?() }
  }
  
  public func append(items: [ListItem], spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.append(items) { completion?() }
  }
  
  public func prepend(items: [ListItem], spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.prepend(items)  { completion?() }
  }

  public func insert(item: ListItem, index: Int = 0, spotIndex: Int, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.insert(item, index: index)  { completion?() }
  }

  public func update(item: ListItem, index: Int = 0, spotIndex: Int, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.update(item, index: index)  { completion?() }
  }

  public func delete(index: Int, spotIndex: Int = 0, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.delete(index) { completion?() }
  }

  public func delete(indexes indexes: [Int], spotIndex: Int, completion: (() -> Void)? = nil) {
    spotAtIndex(spotIndex)?.delete(indexes) { completion?() }
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

extension SpotsController {

  private func component(indexPath: NSIndexPath) -> Component {
    return spot(indexPath).component
  }

  private func spot(indexPath: NSIndexPath) -> Spotable {
    return spots[indexPath.item]
  }

  private func spot(index: Int) -> Spotable {
    return spots[index]
  }
}

extension SpotsController: UICollectionViewDataSource {

  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return spots.count
  }

  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SpotsController.reuseIdentifier, forIndexPath: indexPath)

    (cell as? SpotCell)?.spotView = spot(indexPath.item).render()
    cell.optimize()

    spot(indexPath).sizeDelegate = self
    spot(indexPath).spotDelegate = spotDelegate

    return cell
  }
}

extension SpotsController: UICollectionViewDelegateFlowLayout {

  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    if component(indexPath).size == nil {
      var size = collectionView.frame.size

      if let tabBarController = tabBarController
        where tabBarController.tabBar.translucent {
          (spot(indexPath).render() as? UITableView)?.contentInset.bottom = tabBarController.tabBar.frame.height
          layout.sectionInset.bottom = tabBarController.tabBar.frame.height
          size.height -= collectionView.contentInset.top
      } else if let _ = navigationController {
        (spot(indexPath).render() as? UIScrollView)?.contentInset.bottom = collectionView.contentInset.top
        layout.sectionInset.bottom = 0
      }

      spot(indexPath).setup(size)
      spot(indexPath).component.size = CGSize(
        width: collectionView.frame.width,
        height: ceil(spot(indexPath).render().frame.height))
    }

    return component(indexPath).size!
  }
}

extension SpotsController: SpotSizeDelegate {

  public func sizeDidUpdate() {
    collectionView.collectionViewLayout.invalidateLayout()
  }
}
