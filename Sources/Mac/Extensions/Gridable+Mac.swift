import Cocoa
import Brick

extension Gridable {

  public var responder: NSResponder {
    return collectionView
  }

  public var nextResponder: NSResponder? {
    get {
      return collectionView.nextResponder
    }
    set {
      collectionView.nextResponder = newValue
    }
  }

  // MARK: - Spotable

  public func register() {
    for (identifier, item) in type(of: self).grids.storage {
      switch item {
      case .classType(let classType):
        self.collectionView.register(classType, forItemWithIdentifier: identifier)
      case .nib(let nib):
        self.collectionView.register(nib, forItemWithIdentifier: identifier)
      }
    }
  }

  /**
   - returns: A CGFloat of the total height of all items inside of a component
   */
  public func spotHeight() -> CGFloat {
    guard usesDynamicHeight else {
      return self.render().frame.height
    }

    return layout.collectionViewContentSize.height
  }

  /**
   Asks the data source for the size of an item in a particular location.

   - parameter indexPath: The index path of the
   - returns: Size of the object at index path as CGSize
   */
  public func sizeForItem(at indexPath: IndexPath) -> CGSize {
    var sectionInsets: CGFloat = 0.0
    if let layout = layout as? NSCollectionViewFlowLayout, component.span > 0 {
      component.items[indexPath.item].size.width = (collectionView.frame.width / CGFloat(component.span)) - layout.sectionInset.left - layout.sectionInset.right
      sectionInsets = layout.sectionInset.left + layout.sectionInset.right
    }

    var width = (item(indexPath as IndexPath)?.size.width ?? 0) - sectionInsets
    let height = item(indexPath as IndexPath)?.size.height ?? 0
    // Never return a negative width
    guard width > -1 else {
      return CGSize.zero
    }

    if width >= collectionView.frame.width {
      width -= 2
    }

    let size = CGSize(
      width: floor(width),
      height: ceil(height))

    return size
  }

  public func identifier(_ index: Int) -> String {
    guard let item = item(index), type(of: self).grids.storage[item.kind] != nil
      else {
        return type(of: self).grids.defaultIdentifier
    }

    return item.kind
  }

  /**
   Prepares a view model item before being used by the UI component

   - parameter index: The index of the view model
   - parameter usesViewSize: A boolean value to determine if the view uses the views height
   */
  public func configureItem(at index: Int, usesViewSize: Bool = false) {
    guard let item = item(index) else { return }

    var viewModel = item
    viewModel.index = index

    let kind = item.kind.isEmpty || Self.grids.storage[item.kind] == nil
      ? Self.grids.defaultIdentifier
      : viewModel.kind

    guard let (_, collectionItem) = Self.grids.make(kind),
      let view = collectionItem as? SpotConfigurable else { return }

    view.configure(&viewModel)

    if usesViewSize {
      if viewModel.size.height == 0 {
        viewModel.size.height = view.preferredViewSize.height
      }

      if viewModel.size.width == 0 {
        viewModel.size.width = view.preferredViewSize.width
      }
    }

    if index < component.items.count {
      component.items[index] = viewModel
    }
  }

  public static func register(nib: Nib, identifier: StringConvertible) {
    self.grids.storage[identifier.string] = GridRegistry.Item.nib(nib)
  }

  public func deselect() {
    collectionView.deselectAll(nil)
  }

  public static func register(view: NSCollectionViewItem.Type, identifier: StringConvertible) {
    self.grids.storage[identifier.string] = GridRegistry.Item.classType(view)
  }

  public static func register(defaultView: NSCollectionViewItem.Type) {
    self.grids.storage[self.grids.defaultIdentifier] = GridRegistry.Item.classType(defaultView)
  }
}
