public struct Factory {

  /// The default spot for the Factory
  public static var DefaultSpot: Spotable.Type = GridSpot.self

  /// Defaults spots, it includes carousel, list, grid and view
  private static var spots: [String: Spotable.Type] = [
    Component.Kind.carousel.string: CarouselSpot.self,
    Component.Kind.list.string: ListSpot.self,
    Component.Kind.grid.string: GridSpot.self,
    Component.Kind.row.string: RowSpot.self,
    Component.Kind.view.string: ViewSpot.self,
    Component.Kind.spot.string: Spot.self
  ]

  /// Register a spot for a specfic spot type
  ///
  /// - parameter kind: The reusable identifier that will be used to indentify your view
  /// - parameter spot: A generic spotable type
  public static func register<T: Spotable>(kind: String, spot: T.Type) {
    spots[kind] = spot
  }

  /// Craft spotable object from component struct
  ///
  /// - parameter component: A compontent struct used for crafting the spotable object.
  ///
  /// - returns: A spotable object.
  public static func resolve(component: Component) -> Spotable {
    var resolvedKind = component.kind
    if component.isHybrid {
      resolvedKind = Component.Kind.row.string
    }

    let spot: Spotable.Type = spots[resolvedKind] ?? DefaultSpot

    return spot.init(component: component)
  }
}
