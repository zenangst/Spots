import Quick
import Nimble
import Brick
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

      describe("can be represented as dictionary") {
        let component = Component(title: "ListSpot", kind: "list", span: 1, meta: ["headerHeight" : 44.0])
        let listSpot = ListSpot(component: component)

        it ("represent ListSpot as a dictionary") {
          expect(component.dictionary["index"] as? Int).to(equal(listSpot.dictionary["index"] as? Int))
          expect(component.dictionary["title"] as? String).to(equal(listSpot.dictionary["title"] as? String))
          expect(component.dictionary["kind"] as? String).to(equal(listSpot.dictionary["kind"] as? String))
          expect(component.dictionary["span"] as? Int).to(equal(listSpot.dictionary["span"] as? Int))
          expect((component.dictionary["meta"] as! [String : AnyObject])["headerHeight"] as? CGFloat)
            .to(equal((listSpot.dictionary["meta"] as! [String : AnyObject])["headerHeight"] as? CGFloat))
        }
      }

      describe("can safely resolve kind") {
        let component = Component(title: "ListSpot", kind: "custom-list", items: [ViewModel(title: "foo", kind: "custom-item-kind")])
        let listSpot = ListSpot(component: component)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)

        expect(listSpot.identifier(indexPath)).to(equal("list"))

        ListSpot.views["default-list"] = Registry.Item.classType(ListSpotCell.self)
        expect(listSpot.identifier(indexPath)).to(equal("default-list"))

        ListSpot.views["custom-list"] = Registry.Item.classType(ListSpotCell.self)
        expect(listSpot.identifier(indexPath)).to(equal("custom-list"))

        ListSpot.views["custom-item-kind"] = Registry.Item.classType(ListSpotCell.self)
        expect(listSpot.identifier(indexPath)).to(equal("custom-item-kind"))

        ListSpot.views.storage.removeAll()
      }
    }
  }
}
