import UIKit

public protocol Spotable: class {

  static var views: [String : UIView.Type] { get set }
  static var defaultView: UIView.Type { get set }

  weak var spotsDelegate: SpotsDelegate? { get set }

  var index: Int { get set }
  var component: Component { get set }

  init(component: Component)

  func setup(size: CGSize)
  func append(item: ListItem, completion: (() -> Void)?)
  func append(items: [ListItem], completion: (() -> Void)?)
  func prepend(items: [ListItem], completion: (() -> Void)?)
  func insert(item: ListItem, index: Int, completion: (() -> Void)?)
  func update(item: ListItem, index: Int, completion: (() -> Void)?)
  func delete(index: Int, completion: (() -> Void)?)
  func delete(indexes: [Int], completion: (() -> Void)?)
  func reload(indexes: [Int], completion: (() -> Void)?)
  func render() -> UIScrollView
  func layout(size: CGSize)
  func prepare()
}

public extension Spotable {

  var items: [ListItem] {
    set(items) {
      component.items = items
    }
    get {
      return component.items
    }
  }

  public func item(index: Int) -> ListItem {
    return component.items[index]
  }

  public func item(indexPath: NSIndexPath) -> ListItem {
    return component.items[indexPath.item]
  }

  public func prepare() { }
  public func refreshIndexes() {
    items.enumerate().forEach {
      items[$0.index].index = $0.index
    }
  }
}
