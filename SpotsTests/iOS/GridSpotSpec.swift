import Quick
import Nimble
@testable import Spots

class GridSpotSpec: QuickSpec {

  override func spec() {
    describe("GridSpot") {

      describe("convenience init with title") {
        let gridSpot = GridSpot(title: "Spot")

        it ("sets a title") {
          expect(gridSpot.component.title).to(equal("Spot"))
        }

        it ("sets a default kind") {
          expect(gridSpot.component.kind).to(equal("grid"))
        }
      }

      describe("convenience init with section inset") {
        let component = Component()
        let gridSpot = GridSpot(component,
          top: 5, left: 10, bottom: 5, right: 10, itemSpacing: 5)

        it ("sets section inset") {
          expect(gridSpot.layout.sectionInset).to(equal(UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)))
        }

        it ("sets item spacing") {
          expect(gridSpot.layout.minimumInteritemSpacing).to(equal(5))
        }
      }

      describe("can be represented as dictionary") {
        let component = Component(title: "GridSpot", kind: "grid", span: 3, meta: ["headerHeight" : 44.0])
        let listSpot = GridSpot(component: component)

        it ("represent GridSpot as a dictionary") {
          expect(component.dictionary["index"] as? Int).to(equal(listSpot.dictionary["index"] as? Int))
          expect(component.dictionary["title"] as? String).to(equal(listSpot.dictionary["title"] as? String))
          expect(component.dictionary["kind"] as? String).to(equal(listSpot.dictionary["kind"] as? String))
          expect(component.dictionary["span"] as? Int).to(equal(listSpot.dictionary["span"] as? Int))
          expect((component.dictionary["meta"] as! [String : AnyObject])["headerHeight"] as? CGFloat)
            .to(equal((listSpot.dictionary["meta"] as! [String : AnyObject])["headerHeight"] as? CGFloat))
        }
      }
    }
  }
}
