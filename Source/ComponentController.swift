import UIKit

class ComponentsController: UIViewController {

  private let Components: [Component]
  static let reuseIdentifier = "ComponentCell"

  lazy var collectionView: UICollectionView = { [unowned self] in
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = self.view.bounds.size

    let collectionView = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    return collectionView
  }()

  required init(views: [Component]) {
    self.Components = views
    super.init(nibName: nil, bundle: nil)
    self.view.addSubview(collectionView)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}

extension ComponentsController: UICollectionViewDataSource {

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return Components.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let component = Components[indexPath.item]
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ComponentsController.reuseIdentifier, forIndexPath: indexPath)

    cell.contentView.addSubview(component.render())
    
    return cell
  }
}

