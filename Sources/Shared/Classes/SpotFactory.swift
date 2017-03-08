public struct Factory {

  /// The default component for the Factory
  public static var DefaultSpot: CoreComponent.Type = GridComponent.self

  /// Defaults components, it includes carousel, list, grid and view
  private static var components: [String: CoreComponent.Type] = [
    ComponentModel.Kind.carousel.string: CarouselComponent.self,
    ComponentModel.Kind.list.string: ListComponent.self,
    ComponentModel.Kind.grid.string: GridComponent.self,
    ComponentModel.Kind.row.string: RowComponent.self,
    ComponentModel.Kind.view.string: ViewComponent.self,
    ComponentModel.Kind.component.string: Component.self
  ]

  /// Register a component for a specfic component type
  ///
  /// - parameter kind: The reusable identifier that will be used to indentify your view
  /// - parameter component: A generic component type.
  public static func register<T: CoreComponent>(kind: String, component: T.Type) {
    components[kind] = component
  }

  /// Craft component from component model
  ///
  /// - parameter component: A compontent struct used for crafting The component.
  ///
  /// - returns: A component.
  public static func resolve(model: ComponentModel) -> CoreComponent {
    var resolvedKind = model.kind
    if model.isHybrid {
      resolvedKind = ComponentModel.Kind.component.string
    }

    let component: CoreComponent.Type = components[resolvedKind] ?? DefaultSpot

    return component.init(model: model)
  }
}
