import Cocoa

public class GridSpot: NSObject, Spotable, Gridable {

  public static var cells = [String: NSView.Type]()
  public static var configure: ((view: NSCollectionView) -> Void)?
  public static var defaultCell: NSView.Type = GridSpotCell.self

  public var cachedCells = [String : Itemble]()
  public var component: Component
  public var index = 0

  public weak var spotsDelegate: SpotsDelegate?

  public lazy var layout: NSCollectionViewFlowLayout = NSCollectionViewFlowLayout()

  public lazy var collectionView: NSCollectionView = { [unowned self] in
    let collectionView = NSCollectionView(frame: CGRectZero, collectionViewLayout: self.layout)
    collectionView.backgroundColor = NSColor.whiteColor()
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.scrollEnabled = false

    return collectionView
    }()

  public required init(component: Component) {
    self.component = component
    super.init()
  }

  public convenience init(title: String = "", kind: String = "grid") {
    self.init(component: Component(title: title, kind: kind))
  }

  public convenience init(_ component: Component, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, itemSpacing: CGFloat = 0) {
    self.init(component: component)

    layout.sectionInset = NSEdgeInsetsMake(top, left, bottom, right)
    layout.minimumInteritemSpacing = itemSpacing
  }

  public func setup(size: CGSize) {
    collectionView.frame.size = size
    GridSpot.configure?(view: collectionView)
  }
}
