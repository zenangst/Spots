import UIKit

public protocol Spotable: class {

  static var cells: [String : UIView.Type] { get set }
  static var defaultCell: UIView.Type { get set }

  weak var sizeDelegate: SpotSizeDelegate? { get set }
  weak var spotDelegate: SpotsDelegate? { get set }

  var index: Int { get set }
  var component: Component { get set }
  var cachedCells: [String : Itemble] { get set }

  init(component: Component)

  func setup()
  func append(item: ListItem, completion: (() -> Void)?)
  func append(items: [ListItem], completion: (() -> Void)?)
  func prepend(items: [ListItem], completion: (() -> Void)?)
  func insert(item: ListItem, index: Int, completion: (() -> Void)?)
  func update(item: ListItem, index: Int, completion: (() -> Void)?)
  func delete(index: Int, completion: (() -> Void)?)
  func delete(indexes: [Int], completion: (() -> Void)?)
  func reload(indexes: [Int], completion: (() -> Void)?)
  func render() -> UIView
  func layout(size: CGSize)
}

public extension Spotable {

  public func append(item: ListItem, completion: (() -> Void)? = nil) {}
  public func append(items: [ListItem], completion: (() -> Void)? = nil) {}
  public func prepend(items: [ListItem], completion: (() -> Void)? = nil) {}
  public func insert(item: ListItem, index: Int, completion: (() -> Void)? = nil) {}
  public func update(item: ListItem, index: Int, completion: (() -> Void)? = nil) {}
  public func delete(index: Int, completion: (() -> Void)? = nil) {}
  public func delete(indexs: [Int], completion: (() -> Void)? = nil) {}

  public func sanitizeItems() {
    let unsantizedItems = component.items.filter { $0.kind.isEmpty }

    for (index, _) in unsantizedItems.enumerate() {
      self.component.items[index].kind = component.kind
    }
  }

  public func cellIsCached(kind: String) -> Bool {
    return cachedCells[kind] != nil
  }

  public func item(index: Int) -> ListItem {
    return component.items[index]
  }

  public func item(indexPath: NSIndexPath) -> ListItem {
    return component.items[indexPath.item]
  }
}
