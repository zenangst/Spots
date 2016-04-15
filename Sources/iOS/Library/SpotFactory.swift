public class SpotFactory {

  public static var DefaultSpot: Spotable.Type = GridSpot.self

  private static var spots: [String: Spotable.Type] = [
    "carousel": CarouselSpot.self,
    "list" : ListSpot.self,
    "grid": GridSpot.self,
    "view": ViewSpot.self
  ]

  /**
   Register a spot for a specfic spot type

   - Parameter kind: The reusable identifier that will be used to indentify your view
   - Parameter spot: A generic spotable type
   */
  public static func register<T: Spotable>(kind: String, spot: T.Type) {
    spots[kind] = spot
  }

  /**
   - Parameter component: A component that you want to resolve before initializing the spot
   - Returns: A spotable object
   */
  public static func resolve(component: Component) -> Spotable {
    let spot: Spotable.Type = spots[component.kind] ?? DefaultSpot
    return spot.init(component: component)
  }
}
