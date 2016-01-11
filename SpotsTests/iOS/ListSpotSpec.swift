import Quick
import Nimble
@testable import Spots

class ListSpotSpec: QuickSpec {

  override func spec() {
    describe("ListSpot") {

      describe("init") {
        let component = Component(title: "List")
        let listSpot = ListSpot(component: component)

        it ("sets a title") {
          expect(listSpot.component.title).to(equal("List"))
        }

        it ("sets a default kind") {
          expect(listSpot.component.kind).to(equal("list"))
        }
      }

      describe("convenience init with title") {
        let listSpot = ListSpot(title: "Spot")

        it ("sets a title") {
          expect(listSpot.component.title).to(equal("Spot"))
        }

        it ("sets a default kind") {
          expect(listSpot.component.kind).to(equal("list"))
        }
      }
    }
  }
}
