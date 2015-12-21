public class SpotController: SpotsController {

  public required init(spot: Spotable)  {
    super.init(spots: [spot])
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public required init(spots: [Spotable]) {
    fatalError("init(spots:) has not been implemented")
  }
}
