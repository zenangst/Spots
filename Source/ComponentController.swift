import UIKit

class ComponentsController: UIViewController {

  private let components: [ComponentContainer]
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

  required init(containers: [ComponentContainer]) {
    self.components = containers
    super.init(nibName: nil, bundle: nil)
    self.view.addSubview(collectionView)
    self.view.autoresizingMask = [.FlexibleRightMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleHeight, .FlexibleWidth]
    self.view.autoresizesSubviews = true
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}

extension ComponentsController: UICollectionViewDataSource {

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return components.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let component = components[indexPath.item]
    component.sizeDelegate = self

    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ComponentsController.reuseIdentifier, forIndexPath: indexPath)
    cell.contentView.addSubview(component.render())
    
    return cell
  }
}

extension ComponentsController: UICollectionViewDelegateFlowLayout {

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let component = components[indexPath.item]
    return component.render().frame.size
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 1
  }
}

extension ComponentsController: ComponentSizeDelegate {

  func sizeDidUpdate() {
    collectionView.collectionViewLayout.invalidateLayout()
  }
}
