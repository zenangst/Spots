import Quick
import Nimble
@testable import Spots

class ViewSpotSpec: QuickSpec {

  override func spec() {
    describe("ViewSpot") {

      describe("init") {
        let component = Component(title: "Spot")
        let viewSpot = ViewSpot(component: component)

        it ("sets a title") {
          expect(viewSpot.component.title).to(equal("Spot"))
        }

        it ("sets a default kind") {
          expect(viewSpot.component.kind).to(equal("view"))
        }
      }

      describe("convenience init with title") {
        let viewSpot = ViewSpot(title: "Spot")

        it ("sets a title") {
          expect(viewSpot.component.title).to(equal("Spot"))
        }

        it ("sets a default kind") {
          expect(viewSpot.component.kind).to(equal("view"))
        }
      }
    }
  }
}
