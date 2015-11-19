import UIKit

public protocol Spotable: class {

  var index: Int { get set }
  weak var sizeDelegate: SpotSizeDelegate? { get set }
  weak var spotDelegate: SpotsDelegate? { get set }
  var component: Component { get set }

  init(component: Component)
  func setup()
  func append(item: ListItem, completion: (() -> Void)?)
  func append(items: [ListItem], completion: (() -> Void)?)
  func insert(item: ListItem, index: Int, completion: (() -> Void)?)
  func update(item: ListItem, index: Int, completion: (() -> Void)?)
  func delete(index: Int, completion: (() -> Void)?)
  func delete(indexes: [Int], completion: (() -> Void)?)
  func reload(indexes: [Int], completion: (() -> Void)?)
  func render() -> UIView
  func layout(size: CGSize)
}

extension Spotable {

  public func append(item: ListItem, completion: (() -> Void)? = nil) {}
  public func append(items: [ListItem], completion: (() -> Void)? = nil) {}
  public func insert(item: ListItem, index: Int, completion: (() -> Void)? = nil) {}
  public func update(item: ListItem, index: Int, completion: (() -> Void)? = nil) {}
  public func delete(index: Int, completion: (() -> Void)? = nil) {}
  public func delete(indexs: [Int], completion: (() -> Void)? = nil) {}

}
