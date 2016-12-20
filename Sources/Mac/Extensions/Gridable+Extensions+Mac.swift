import Cocoa
import Brick

extension Gridable {

  public func reloadIfNeeded(_ changes: ItemChanges, withAnimation animation: Animation, updateDataSource: () -> Void, completion: Completion) {
    guard !changes.updates.isEmpty else {
      collectionView.process((insertions: changes.insertions, reloads: changes.reloads, deletions: changes.deletions), updateDataSource: updateDataSource, completion: completion)
      return
    }

    collectionView.process((insertions: changes.insertions, reloads: changes.reloads, deletions: changes.deletions), updateDataSource: updateDataSource) { [weak self] in

      for index in changes.updates {
        guard let item = self?.item(at: index) else { continue }
        self?.update(item, index: index, withAnimation: animation, completion: completion)
      }
    }
  }

  public func refreshHeight(_ completion: (() -> Void)? = nil) {
    Dispatch.delay(for: 0.2) { [weak self] in
      guard let weakSelf = self, let collectionView = self?.collectionView else { return; completion?() }
      weakSelf.setup(CGSize(width: collectionView.frame.width, height: weakSelf.computedHeight ))
      completion?()
    }
  }

  /// A computed CGFloat of the total height of all items inside of a component
  public var computedHeight: CGFloat {
    guard usesDynamicHeight else {
      return self.render().frame.height
    }

    return layout.collectionViewContentSize.height
  }

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

    var width = (item(at: indexPath)?.size.width ?? 0) - sectionInsets
    let height = item(at: indexPath)?.size.height ?? 0
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

  public func identifier(at index: Int) -> String {
    guard let item = item(at: index), type(of: self).grids.storage[item.kind] != nil
      else {
        return type(of: self).grids.defaultIdentifier
    }

    return item.kind
  }

  /// Prepares a view model item before being used by the UI component
  ///
  /// - parameter index:        The index of the view model
  /// - parameter usesViewSize: A boolean value to determine if the view uses the views height
  public func configureItem(at index: Int, usesViewSize: Bool = false) {
    guard var item = item(at: index) else { return }

    item.index = index

    let kind = item.kind.isEmpty || Self.grids.storage[item.kind] == nil
      ? Self.grids.defaultIdentifier
      : item.kind

    guard let (_, collectionItem) = Self.grids.make(kind),
      let view = collectionItem as? SpotConfigurable else { return }

    view.configure(&item)

    if usesViewSize {
      if item.size.height == 0 {
        item.size.height = view.preferredViewSize.height
      }

      if item.size.width == 0 {
        item.size.width = view.preferredViewSize.width
      }
    }

    if index < component.items.count {
      component.items[index] = item
    }
  }

  func registerComposite(view: NSCollectionViewItem.Type) {
    if type(of: self).grids.composite == nil {
      type(of: self).grids.composite = GridRegistry.Item.classType(view)
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

  /// Register default view for the Spotable object
  ///
  /// - parameter view: The view type that should be used as the default view
  func registerDefault(view: NSCollectionViewItem.Type) {
    if type(of: self).grids.storage[type(of: self).views.defaultIdentifier] == nil {
      type(of: self).grids.defaultItem = GridRegistry.Item.classType(view)
    }
  }

  public func afterUpdate() {
    setup(collectionView.frame.size)
  }
}
