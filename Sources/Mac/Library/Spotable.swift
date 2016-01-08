import Cocoa

public protocol Spotable: class {

  static var cells: [String : NSView.Type] { get set }
  static var defaultCell: NSView.Type { get set }

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
  func render() -> NSScrollView
  func layout(size: CGSize)
  func prepare()
}
