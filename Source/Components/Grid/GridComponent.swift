import UIKit
import GoldenRetriever

class GridComponent: NSObject, ComponentContainer {

  static var cells = [String: UICollectionViewCell.Type]()

  var component: Component
  weak var sizeDelegate: ComponentSizeDelegate?

  lazy var layout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 88, height: 88)

    return layout
    }()

  lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.layout)
    collectionView.frame.size.width = UIScreen.mainScreen().bounds.width
    collectionView.dataSource = self
    collectionView.backgroundColor = UIColor.whiteColor()

    return collectionView
    }()

  required init(component: Component) {
    self.component = component
    super.init()
    for item in component.items {
      let componentCellClass = GridComponent.cells[item.type] ?? UICollectionViewCell.self
      self.collectionView.registerClass(componentCellClass, forCellWithReuseIdentifier: "GridCell\(item.type)")
    }
  }

  func render() -> UIView
  {
    collectionView.frame.size.height = layout.collectionViewContentSize().height
    return collectionView
  }
}

extension GridComponent: UICollectionViewDataSource {

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return component.items.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let item = component.items[indexPath.item]

    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GridCell\(item.type)", forIndexPath: indexPath)

    if item.image != "" {
      let resource = item.image
      let fido = GoldenRetriever()
      fido.fetch(resource) { data, error in
        guard let data = data else { return }
        let image = UIImage(data: data)
        cell.backgroundColor = UIColor(patternImage: image!)
      }
    } else {
      cell.backgroundColor = UIColor.lightGrayColor()
    }

    let label = UILabel(frame: CGRect(x: 0,y: 0,width: 88,height: 88))
    label.text = item.title
    label.textAlignment = .Center
    cell.addSubview(label)

    return cell
  }
}
