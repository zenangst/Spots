public struct Factory {

  /// The default spot for the Factory
  public static var DefaultSpot: CoreComponent.Type = GridComponent.self

  /// Defaults components, it includes carousel, list, grid and view
  private static var components: [String: CoreComponent.Type] = [
    ComponentModel.Kind.carousel.string: CarouselComponent.self,
    ComponentModel.Kind.list.string: ListComponent.self,
    ComponentModel.Kind.grid.string: GridComponent.self,
    ComponentModel.Kind.row.string: RowComponent.self,
    ComponentModel.Kind.view.string: ViewComponent.self,
    ComponentModel.Kind.spot.string: Component.self
  ]

  /// Register a spot for a specfic spot type
  ///
  /// - parameter kind: The reusable identifier that will be used to indentify your view
  /// - parameter spot: A generic spotable type
  public static func register<T: CoreComponent>(kind: String, spot: T.Type) {
    components[kind] = spot
  }

  /// Craft spotable object from component struct
  ///
  /// - parameter component: A compontent struct used for crafting the spotable object.
  ///
  /// - returns: A spotable object.
  public static func resolve(model: ComponentModel) -> CoreComponent {
    var resolvedKind = model.kind
    if model.isHybrid {
      resolvedKind = ComponentModel.Kind.spot.string
    }

    let spot: CoreComponent.Type = components[resolvedKind] ?? DefaultSpot

    return spot.init(model: model)
  }
}
