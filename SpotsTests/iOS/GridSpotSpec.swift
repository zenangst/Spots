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
    }
  }
}
