import Foundation

extension ComponentResolvable {
  /// Resolve a component and return it in a generic closure, otherwise return the fallback.
  ///
  /// - Parameters:
  ///   - closure: The resovled component gets passed into the closure if it manages to resolved it.
  ///   - fallback: The fallback value that should be returned if the component cannot be resolved.
  /// - Returns: If the component is resolved then the closure manages the result, other wise use the fallback.
  @discardableResult func resolveComponent<T>(_ closure: (Component) -> T, fallback: @autoclosure () -> T) -> T {
    guard let component = component else {
      return fallback()
    }

    return closure(component)
  }

  /// Resolve component from instance.
  ///
  /// - Parameter closure: Passes the resolved component to the closure.
  func resolveComponent(_ closure: (Component) -> Void) {
    guard let component = component else {
      return
    }

    closure(component)
  }

  /// Resolve component and item at a specific index path inside the component.
  ///
  /// - Parameters:
  ///   - indexPath: The index path of the item that should be resolved.
  ///   - closure: The resolved component and item gets passed into the closure.
  func resolveComponentItem(at indexPath: IndexPath, _ closure: (Component, Item) -> Void) {
    guard let component = component else {
      return
    }

    guard let item = component.item(at: indexPath) else {
      return
    }

    closure(component, item)
  }
}
