import UIKit
import GoldenRetriever
import Sugar

class GridSpot: NSObject, Spotable {

  static var cells = [String: UICollectionViewCell.Type]()

  var component: Component
  weak var sizeDelegate: SpotSizeDelegate?

  lazy var flowLayout: UICollectionViewFlowLayout = {
    let size = UIScreen.mainScreen().bounds.width / CGFloat(self.component.span)
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    layout.itemSize = CGSize(width: floor(size), height: 88)

    return layout
    }()

  lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.flowLayout)
    collectionView.frame.size.width = UIScreen.mainScreen().bounds.width
    collectionView.dataSource = self
    collectionView.backgroundColor = UIColor.whiteColor()

    return collectionView
    }()

  required init(component: Component) {
    self.component = component
    super.init()
    for item in component.items {
      let componentCellClass = GridSpot.cells[item.type] ?? UICollectionViewCell.self
      self.collectionView.registerClass(componentCellClass, forCellWithReuseIdentifier: "GridCell\(item.type)")
    }
  }

  func render() -> UIView {
    collectionView.frame.size.height = flowLayout.collectionViewContentSize().height
    return collectionView
  }
}

extension GridSpot: UICollectionViewDataSource {

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return component.items.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let item = component.items[indexPath.item]

    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GridCell\(item.type)", forIndexPath: indexPath)

    if item.image != "" {
      let resource = item.image
      let fido = GoldenRetriever()
      let qualityOfServiceClass = QOS_CLASS_BACKGROUND
      let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)

      dispatch(backgroundQueue) {
        fido.fetch(resource) { data, error in
          guard let data = data else { return }
          let image = UIImage(data: data)
          dispatch {
            cell.backgroundColor = UIColor(patternImage: image!)
          }
        }
      }
    } else {
      cell.backgroundColor = UIColor.lightGrayColor()
    }

    let label = UILabel(frame: CGRect(x: 0,y: 0,width: layout.itemSize.width, height: layout.itemSize.height))
    label.text = item.title
    label.textAlignment = .Center
    cell.addSubview(label)

    return cell
  }
}
