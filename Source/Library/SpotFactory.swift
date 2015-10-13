public class SpotFactory {

  private static var spots: [String: Spotable.Type] = [
    "carousel": CarouselSpot.self,
    "list" : ListSpot.self,
    "grid": GridSpot.self,
    "pages": PagesSpot.self
  ]

  static func register<T: Spotable>(kind: String, spot: T.Type) {
    spots[kind] = spot
  }

  static func resolve(component: Component) -> Spotable {
    let Spot: Spotable.Type = spots[component.kind] ?? GridSpot.self
    return Spot.init(component: component)
  }
}
