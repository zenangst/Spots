public class SpotController: SpotsController {

  public convenience init(spot: Spotable)  {
    self.init(spots: [spot])
  }
}
