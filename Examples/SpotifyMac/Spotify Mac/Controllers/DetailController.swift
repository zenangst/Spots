import Spots
import Brick
import Compass
import Malibu
import Sugar
import Tailor

class DetailController: SpotsController, SpotsDelegate, SpotsScrollDelegate {

  var blueprint: Blueprint? {
    didSet {
      guard let blueprint = blueprint else { return }

      self.source = nil
      let newCache = SpotCache(key: blueprint.cacheKey)
      self.stateCache = newCache
      var spots = newCache.load()

      if spots.isEmpty {
        spots = blueprint.template
      }

      reloadSpots(Parser.parse(spots)) {
        self.process(self.fragments)
        self.build(blueprint)
        self.spotsScrollView.layoutSubtreeIfNeeded()
        self.spotsDelegate = self
      }
    }
  }

  var fragments: [String : AnyObject] = [:]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    spotsScrollView.frame.origin.y = -40
  }

  override func viewWillAppear() {
    super.viewWillAppear()
    guard let blueprint = blueprint else { return }
    build(blueprint)
    self.spotsScrollDelegate = self
  }

  func build(blueprint: Blueprint) {
    for element in blueprint.requests {
      guard let request = element.request else { return }
      Malibu.networking("api").GET(request)
        .validate()
        .toJSONDictionary()
        .done { json in
          var items: JSONArray
          if let rootElementItems = json.path(element.rootKey)?.array("items") {
            items = rootElementItems
          } else {
            if let rootItems = json.array("items") {
              items = rootItems
            } else {
              guard let secondaryItems = json.array(element.rootKey) else { return }
              items = secondaryItems
            }
          }

          let viewModels = element.adapter(json: items)
          self.updateIfNeeded(spotAtIndex: element.spotIndex, items: viewModels) {
            self.cache()
          }
        }.fail { error in
          NSLog("request: \(request.message)")
          NSLog("error: \(error)")
      }
    }
  }

  func process(fragments: [String : AnyObject]? = nil) {
    guard let handler = blueprint?.fragmentHandler, fragments = fragments where fragments["skipHistory"] == nil else { return }

    handler(fragments: fragments, controller: self)
  }
}

extension DetailController {

  func spotDidSelectItem(spot: Spotable, item: ViewModel) {
    guard let action = item.action else { return }

    if item.kind == "track" {
      for item in spot.items where item.meta("playing", type: Bool.self) == true {
        var item = item
        item.meta["playing"] = false
        update(item, index: item.index, spotIndex: spot.index, withAnimation: .None, completion: nil)
      }
      var item = item
      item.meta["playing"] = true
      update(item, index: item.index, spotIndex: spot.index, withAnimation: .None, completion: nil)
    }

    AppDelegate.navigate(action, fragments: item.meta("fragments", [:]))
  }
}

extension DetailController {

  func spotDidReachBeginning(completion: Completion) {
    completion?()
  }

  func spotDidReachEnd(completion: Completion) {
    completion?()
  }
}
