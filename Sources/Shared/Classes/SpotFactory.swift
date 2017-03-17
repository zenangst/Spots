public struct Factory {

  /// The default component for the Factory
  public static var DefaultSpot: Component.Type = GridComponent.self

  /// Defaults components, it includes carousel, list, grid and view
  private static var components: [String: Component.Type] = [
    ComponentModel.Kind.carousel.string: CarouselComponent.self,
    ComponentModel.Kind.list.string: ListComponent.self,
    ComponentModel.Kind.grid.string: GridComponent.self,
    ComponentModel.Kind.row.string: RowComponent.self,
    ComponentModel.Kind.component.string: Component.self
  ]

  /// Register a component for a specfic component type
  ///
  /// - parameter kind: The reusable identifier that will be used to indentify your view
  /// - parameter component: A generic component type.
  public static func register<T: Component>(kind: String, component: T.Type) {
    components[kind] = component
  }

  /// Craft component from component model
  ///
  /// - parameter component: A compontent struct used for crafting The component.
  ///
  /// - returns: A component.
  public static func resolve(model: ComponentModel) -> Component {
    var resolvedKind = model.kind
    if model.isHybrid {
      resolvedKind = ComponentModel.Kind.component.string
    }

    let component: Component.Type = components[resolvedKind] ?? DefaultSpot

    return component.init(model: model)
  }
}
