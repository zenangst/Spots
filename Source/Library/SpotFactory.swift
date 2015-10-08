class SpotFactory {

  private static var spots: [String: Spotable.Type] = [
    "carousel": CarouselSpot.self,
    "list" : ListSpot.self,
    "grid": GridSpot.self
  ]

  static func register<T: Spotable>(key: String, spot: T.Type) {
    spots[key] = spot
  }

  static func resolve(component: Component) -> Spotable {
    let Spot: Spotable.Type = spots[component.type] ?? GridSpot.self
    return Spot.init(component: component)
  }
}
