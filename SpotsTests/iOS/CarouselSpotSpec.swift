import Quick
import Nimble
@testable import Spots

class CarouselSpotSpec: QuickSpec {

  override func spec() {
    describe("CarouselSpot") {

      describe("convenience init with title") {
        let carouselSpot = GridSpot(title: "Spot")

        it ("sets a title") {
          expect(carouselSpot.component.title).to(equal("Spot"))
        }

        it ("sets a default kind") {
          expect(carouselSpot.component.kind).to(equal("grid"))
        }
      }

      describe("convenience init with section inset") {
        let component = Component()
        let carouselSpot = GridSpot(component,
          top: 5, left: 10, bottom: 5, right: 10, itemSpacing: 5)

        it ("sets section inset") {
          expect(carouselSpot.layout.sectionInset).to(equal(UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)))
        }

        it ("sets item spacing") {
          expect(carouselSpot.layout.minimumInteritemSpacing).to(equal(5))
        }
      }
    }
  }
}
