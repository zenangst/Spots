import UIKit

class ComponentsController: UIViewController {

  private let components: [Component]

  lazy var collectionView: UICollectionView = { [unowned self] in
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = self.view.bounds.size

    let collectionView = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "ComponentCell")

    return collectionView
  }()

  required init(components: [Component]) {
    self.components = components
    super.init(nibName: nil, bundle: nil)
    self.view.addSubview(collectionView)
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
    let view = components[indexPath.item]
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ComponentCell", forIndexPath: indexPath)
    cell.contentView.addSubview(view.render())
    return cell
  }
}

