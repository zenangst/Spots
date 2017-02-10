@testable import Spots
import Foundation
import XCTest

class CompositionTests: XCTestCase {

  #if os(tvOS)
  let heightOffset: CGFloat = 0
  #elseif os(iOS)
  let heightOffset: CGFloat = 0
  #else
  let heightOffset: CGFloat = 2
  #endif

  func testComponentCreation() {
    var component = Component(
      kind: Component.Kind.grid.rawValue,
      span: 1.0
    )

    component.add(child: Component(kind: Component.Kind.list.rawValue, span: 1.0))

    XCTAssertEqual(component.items.count, 1)

    component.add(children: [
      Component(kind: Component.Kind.list.rawValue, span: 1.0),
      Component(kind: Component.Kind.list.rawValue, span: 1.0)
      ]
    )

    XCTAssertEqual(component.items.count, 3)
  }

  func testSpotableCreation() {
    let layout = Layout().mutate { $0.span = 2.0 }
    var component = Component(kind: Component.Kind.grid.rawValue, layout: layout)

    component.add(children: [
      Component(
        kind: Component.Kind.list.rawValue,
        span: 1.0,
        items: [
          Item(title: "foo"),
          Item(title: "bar")
        ]
      ),
      Component(
        kind: Component.Kind.list.rawValue,
        span: 1.0,
        items: [
          Item(title: "baz"),
          Item(title: "bal")
        ]
      )
      ]
    )

    let spot = GridSpot(component: component)

    XCTAssertEqual(spot.items.count, 2)
    XCTAssertEqual(spot.compositeSpots.count, 2)
    XCTAssertEqual(spot.compositeSpots[0].spot.component.kind, Component.Kind.list.rawValue)
    XCTAssertEqual(spot.compositeSpots[0].spot.items.count, 2)
    XCTAssertEqual(spot.compositeSpots[0].spot.items[0].title, "foo")
    XCTAssertEqual(spot.compositeSpots[0].spot.items[1].title, "bar")

    XCTAssertEqual(spot.compositeSpots[1].spot.component.kind, Component.Kind.list.rawValue)
    XCTAssertEqual(spot.compositeSpots[1].spot.items.count, 2)
    XCTAssertEqual(spot.compositeSpots[1].spot.items[0].title, "baz")
    XCTAssertEqual(spot.compositeSpots[1].spot.items[1].title, "bal")
  }

  func testUICreation() {
    var component = Component(kind: Component.Kind.grid.rawValue, span: 2.0)

    component.add(children: [
      Component(
        kind: Component.Kind.list.rawValue,
        span: 1,
        items: [
          Item(title: "foo"),
          Item(title: "bar")
        ]
      ),
      Component(
        kind: Component.Kind.list.rawValue,
        span: 1,
        items: [
          Item(title: "baz"),
          Item(title: "bal")
        ]
      )
      ]
    )

    let spot = GridSpot(component: component)
    spot.setup(CGSize(width: 200, height: 200))
    spot.layout(CGSize(width: 200, height: 200))
    spot.view.layoutSubviews()

    var composite: Composable?
    var ItemConfigurable: ItemConfigurable?

    composite = spot.ui(at: 0)
    ItemConfigurable = spot.compositeSpots[0].spot.ui(at: 0)

    XCTAssertNotNil(composite)
    XCTAssertNotNil(ItemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spot.compositeSpots[0].parentSpot!.component == spot.component)
    XCTAssertTrue(spot.compositeSpots[0].spot is Listable)
    XCTAssertEqual(spot.compositeSpots[0].spot.view.frame.size.height,
                   (ItemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(spot.compositeSpots[0].spot.items.count))

    composite = spot.ui(at: 1)
    ItemConfigurable = spot.compositeSpots[0].spot.ui(at: 1)

    XCTAssertNotNil(composite)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spot.compositeSpots[1].parentSpot!.component == spot.component)
    XCTAssertTrue(spot.compositeSpots[1].spot is Listable)
    XCTAssertEqual(spot.compositeSpots[1].spot.view.frame.size.height,
                   (ItemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(spot.compositeSpots[1].spot.items.count))

    composite = spot.ui(at: 2)
    XCTAssertNil(composite)
  }

  func testReloadWithComponentsUsingCompositionTriggeringReplaceSpot() {
    let initialComponents: [Component] = [
      Component(kind: Component.Kind.grid.rawValue,
                span: 2.0,
                items: [
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      ),
      Component(kind: Component.Kind.grid.rawValue,
                span: 2.0,
                items: [
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      )
    ]

    let controller = Controller(spots: Parser.parse(initialComponents))
    controller.prepareController()
    controller.view.layoutIfNeeded()

    let spots = controller.spots

    XCTAssertEqual(spots.count, 2)

    var composite: Composable?
    var ItemConfigurable: ItemConfigurable?

    composite = spots[0].ui(at: 0)
    ItemConfigurable = spots[0].compositeSpots[0].spot.ui(at: 0)

    XCTAssertNotNil(composite)
    XCTAssertNotNil(ItemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spots[0].compositeSpots[0].parentSpot!.component == spots[0].component)
    XCTAssertTrue(spots[0].compositeSpots[0].spot is Listable)
    XCTAssertEqual(spots[0].compositeSpots[0].spot.items.count, 10)
    XCTAssertEqual(spots[0].compositeSpots[0].spot.view.frame.size.height,
                   (ItemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(spots[0].compositeSpots[0].spot.items.count))

    ItemConfigurable = spots[0].compositeSpots[1].spot.ui(at: 0)

    XCTAssertNotNil(ItemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spots[0].compositeSpots[1].parentSpot!.component == spots[0].component)
    XCTAssertTrue(spots[0].compositeSpots[1].spot is Listable)
    XCTAssertEqual(spots[0].compositeSpots[1].spot.items.count, 10)
    XCTAssertEqual(spots[0].compositeSpots[1].spot.view.frame.size.height,
                   (ItemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(spots[0].compositeSpots[1].spot.items.count))

    XCTAssertNotNil(composite)
    XCTAssertNotNil(ItemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spots[1].compositeSpots[0].parentSpot!.component == spots[1].component)
    XCTAssertTrue(spots[1].compositeSpots[0].spot is Listable)
    XCTAssertEqual(spots[1].compositeSpots[0].spot.items.count, 10)
    XCTAssertEqual(spots[1].compositeSpots[0].spot.view.frame.size.height,
                   (ItemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(spots[1].compositeSpots[0].spot.items.count))

    ItemConfigurable = spots[0].compositeSpots[1].spot.ui(at: 0)

    XCTAssertNotNil(ItemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spots[1].compositeSpots[1].parentSpot!.component == spots[1].component)
    XCTAssertTrue(spots[1].compositeSpots[1].spot is Listable)
    XCTAssertEqual(spots[1].compositeSpots[1].spot.items.count, 10)
    XCTAssertEqual(spots[1].compositeSpots[1].spot.view.frame.size.height,
                   (ItemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(spots[1].compositeSpots[1].spot.items.count))

    let newComponents: [Component] = [
      Component(kind: Component.Kind.grid.rawValue,
                span: 1.0,
                items: [
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      ),
      Component(kind: Component.Kind.grid.rawValue,
                span: 3.0,
                items: [
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      )
    ]

    let exception = self.expectation(description: "Reload controller with components replaceSpot")
    var reloadTimes: Int = 0

    controller.reloadIfNeeded(newComponents) {
      reloadTimes += 1

      let spots = controller.spots

      composite = spots[0].ui(at: 0)
      ItemConfigurable = spots[0].compositeSpots[0].spot.ui(at: 0)

      XCTAssertNotNil(composite)
      XCTAssertNotNil(ItemConfigurable)
      XCTAssertNotNil(composite?.contentView)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(spots[0].compositeSpots[0].parentSpot!.component == spots[0].component)
      XCTAssertTrue(spots[0].compositeSpots[0].spot is Listable)
      XCTAssertEqual(spots[0].compositeSpots[0].spot.items.count, 10)
      XCTAssertEqual(spots[0].compositeSpots[0].spot.view.frame.size.height,
                     ((ItemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(spots[0].compositeSpots[0].spot.items.count))

      ItemConfigurable = spots[0].compositeSpots[1].spot.ui(at: 0)

      XCTAssertNotNil(ItemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(spots[0].compositeSpots[1].parentSpot!.component == spots[0].component)
      XCTAssertTrue(spots[0].compositeSpots[1].spot is Listable)
      XCTAssertEqual(spots[0].compositeSpots[1].spot.items.count, 10)
      XCTAssertEqual(spots[0].compositeSpots[1].spot.view.frame.size.height,
                     ((ItemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(spots[0].compositeSpots[1].spot.items.count))

      XCTAssertNotNil(composite)
      XCTAssertNotNil(ItemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(spots[1].compositeSpots[0].parentSpot!.component == spots[1].component)
      XCTAssertTrue(spots[1].compositeSpots[0].spot is Listable)
      XCTAssertEqual(spots[1].compositeSpots[0].spot.items.count, 10)
      XCTAssertEqual(spots[1].compositeSpots[0].spot.view.frame.size.height,
                     ((ItemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(spots[1].compositeSpots[0].spot.items.count))

      ItemConfigurable = spots[0].compositeSpots[1].spot.ui(at: 0)

      XCTAssertNotNil(ItemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(spots[1].compositeSpots[1].parentSpot!.component == spots[1].component)
      XCTAssertTrue(spots[1].compositeSpots[1].spot is Listable)
      XCTAssertEqual(spots[1].compositeSpots[1].spot.items.count, 10)
      XCTAssertEqual(spots[1].compositeSpots[1].spot.view.frame.size.height,
                     ((ItemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(spots[1].compositeSpots[1].spot.items.count))

      XCTAssertEqual(reloadTimes, 1)

      exception.fulfill()
    }
    waitForExpectations(timeout: 1.0, handler: nil)
  }

  func testReloadWithComponentsUsingCompositionTriggeringNewSpot() {
    let initialComponents: [Component] = []
    let controller = Controller(spots: Parser.parse(initialComponents))
    controller.prepareController()
    controller.view.layoutIfNeeded()

    let spots = controller.spots

    XCTAssertEqual(spots.count, 0)

    var composite: Composable?
    var ItemConfigurable: ItemConfigurable?

    let newComponents: [Component] = [
      Component(kind: Component.Kind.grid.rawValue,
                span: 1.0,
                items: [
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      ),
      Component(kind: Component.Kind.grid.rawValue,
                span: 3.0,
                items: [
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      )
    ]

    let exception = self.expectation(description: "Reload controller with components newSpot")
    var reloadTimes: Int = 0

    controller.reloadIfNeeded(newComponents) {
      reloadTimes += 1

      let spots = controller.spots

      composite = spots[0].ui(at: 0)
      ItemConfigurable = spots[0].compositeSpots[0].spot.ui(at: 0)

      XCTAssertNotNil(composite)
      XCTAssertNotNil(ItemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(spots[0].compositeSpots[0].parentSpot!.component == spots[0].component)
      XCTAssertTrue(spots[0].compositeSpots[0].spot is Listable)
      XCTAssertEqual(spots[0].compositeSpots[0].spot.items.count, 10)
      XCTAssertEqual(spots[0].compositeSpots[0].spot.view.frame.size.height,
                     ((ItemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(spots[0].compositeSpots[0].spot.items.count))

      ItemConfigurable = spots[0].compositeSpots[1].spot.ui(at: 0)

      XCTAssertNotNil(ItemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(spots[0].compositeSpots[1].parentSpot!.component == spots[0].component)
      XCTAssertTrue(spots[0].compositeSpots[1].spot is Listable)
      XCTAssertEqual(spots[0].compositeSpots[1].spot.items.count, 10)
      XCTAssertEqual(spots[0].compositeSpots[1].spot.view.frame.size.height,
                     ((ItemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(spots[0].compositeSpots[1].spot.items.count))

      XCTAssertNotNil(composite)
      XCTAssertNotNil(ItemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(spots[1].compositeSpots[0].parentSpot!.component == spots[1].component)
      XCTAssertTrue(spots[1].compositeSpots[0].spot is Listable)
      XCTAssertEqual(spots[1].compositeSpots[0].spot.items.count, 10)
      XCTAssertEqual(spots[1].compositeSpots[0].spot.view.frame.size.height,
                     ((ItemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(spots[1].compositeSpots[0].spot.items.count))

      ItemConfigurable = spots[0].compositeSpots[1].spot.ui(at: 0)

      XCTAssertNotNil(ItemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(spots[1].compositeSpots[1].parentSpot!.component == spots[1].component)
      XCTAssertTrue(spots[1].compositeSpots[1].spot is Listable)
      XCTAssertEqual(spots[1].compositeSpots[1].spot.items.count, 10)
      XCTAssertEqual(spots[1].compositeSpots[1].spot.view.frame.size.height,
                     ((ItemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(spots[1].compositeSpots[1].spot.items.count))

      XCTAssertEqual(reloadTimes, 1)

      exception.fulfill()
    }
    waitForExpectations(timeout: 1.0, handler: nil)
  }

  func testReloadWithComponentsUsingCompositionTriggeringReloadMore() {
    let initialComponents: [Component] = [
      Component(kind: Component.Kind.grid.rawValue,
                span: 2.0,
                items: [
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      ),
      Component(kind: Component.Kind.grid.rawValue,
                span: 2.0,
                items: [
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      )
    ]

    let controller = Controller(spots: Parser.parse(initialComponents))
    controller.prepareController()
    controller.view.layoutIfNeeded()

    let spots = controller.spots

    XCTAssertEqual(spots.count, 2)

    var composite: Composable?
    var ItemConfigurable: ItemConfigurable?

    composite = spots[0].ui(at: 0)
    ItemConfigurable = spots[0].compositeSpots[0].spot.ui(at: 0)

    XCTAssertNotNil(composite)
    XCTAssertNotNil(ItemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spots[0].compositeSpots[0].parentSpot!.component == spots[0].component)
    XCTAssertTrue(spots[0].compositeSpots[0].spot is Listable)
    XCTAssertEqual(spots[0].compositeSpots[0].spot.items.count, 10)
    XCTAssertEqual(spots[0].compositeSpots[0].spot.view.frame.size.height,
                   (ItemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(spots[0].compositeSpots[0].spot.items.count))

    ItemConfigurable = spots[0].compositeSpots[1].spot.ui(at: 0)

    XCTAssertNotNil(ItemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spots[0].compositeSpots[1].parentSpot!.component == spots[0].component)
    XCTAssertTrue(spots[0].compositeSpots[1].spot is Listable)
    XCTAssertEqual(spots[0].compositeSpots[1].spot.items.count, 10)
    XCTAssertEqual(spots[0].compositeSpots[1].spot.view.frame.size.height,
                   (ItemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(spots[0].compositeSpots[1].spot.items.count))

    XCTAssertNotNil(composite)
    XCTAssertNotNil(ItemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spots[1].compositeSpots[0].parentSpot!.component == spots[1].component)
    XCTAssertTrue(spots[1].compositeSpots[0].spot is Listable)
    XCTAssertEqual(spots[1].compositeSpots[0].spot.items.count, 10)
    XCTAssertEqual(spots[1].compositeSpots[0].spot.view.frame.size.height,
                   (ItemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(spots[1].compositeSpots[0].spot.items.count))

    ItemConfigurable = spots[0].compositeSpots[1].spot.ui(at: 0)

    XCTAssertNotNil(ItemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spots[1].compositeSpots[1].parentSpot!.component == spots[1].component)
    XCTAssertTrue(spots[1].compositeSpots[1].spot is Listable)
    XCTAssertEqual(spots[1].compositeSpots[1].spot.items.count, 10)
    XCTAssertEqual(spots[1].compositeSpots[1].spot.view.frame.size.height,
                   (ItemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(spots[1].compositeSpots[1].spot.items.count))

    let newComponents: [Component] = [
      Component(kind: Component.Kind.grid.rawValue,
                span: 2.0,
                items: [
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10"),
                        Item(title: "Item 11")
                        ]
                      )
                    ]
                  ),
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      ),
      Component(kind: Component.Kind.grid.rawValue,
                span: 2.0,
                items: [
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10"),
                        Item(title: "Item 11")
                        ]
                      )
                    ]
                  ),
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10"),
                        Item(title: "Item 11")
                        ]
                      )
                    ]
                  )
        ]
      ),
      Component(kind: Component.Kind.grid.rawValue,
                span: 2.0,
                items: [
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10"),
                        Item(title: "Item 11")
                        ]
                      )
                    ]
                  ),
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10"),
                        Item(title: "Item 11")
                        ]
                      )
                    ]
                  )
        ]
      )
    ]

    let exception: XCTestExpectation = self.expectation(description: "Reload controller with components triggering reloadMore")
    var reloadTimes: Int = 0

    controller.reloadIfNeeded(newComponents) {
      reloadTimes += 1

      let spots = controller.spots

      XCTAssertEqual(spots.count, 3)

      composite = spots[0].ui(at: 0)
      ItemConfigurable = spots[0].compositeSpots[0].spot.ui(at: 0)

      XCTAssertNotNil(composite)
      XCTAssertNotNil(ItemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(spots[0].compositeSpots[0].parentSpot?.component == spots[0].component)
      XCTAssertTrue(spots[0].compositeSpots[0].spot is Listable)
      XCTAssertEqual(spots[0].compositeSpots[0].spot.items.count, 11)
      XCTAssertEqual(spots[0].compositeSpots[0].spot.view.frame.size.height,
                     ((ItemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(spots[0].compositeSpots[0].spot.items.count))

      ItemConfigurable = spots[0].compositeSpots[1].spot.ui(at: 0)

      XCTAssertNotNil(ItemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(spots[0].compositeSpots[1].parentSpot!.component == spots[0].component)
      XCTAssertTrue(spots[0].compositeSpots[1].spot is Listable)
      XCTAssertEqual(spots[0].compositeSpots[1].spot.items.count, 10)
      XCTAssertEqual(spots[0].compositeSpots[1].spot.view.frame.size.height,
                     ((ItemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(spots[0].compositeSpots[1].spot.items.count))

      ItemConfigurable = spots[1].compositeSpots[0].spot.ui(at: 0)

      XCTAssertNotNil(composite)
      XCTAssertNotNil(ItemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(spots[1].compositeSpots[0].parentSpot?.component == spots[1].component)
      XCTAssertTrue(spots[1].compositeSpots[0].spot is Listable)
      XCTAssertEqual(spots[1].compositeSpots[0].spot.items.count, 11)
      XCTAssertEqual(spots[1].compositeSpots[0].spot.view.frame.size.height,
                     ((ItemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(spots[1].compositeSpots[0].spot.items.count))

      ItemConfigurable = spots[1].compositeSpots[1].spot.ui(at: 0)

      XCTAssertNotNil(ItemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(spots[1].compositeSpots[1].parentSpot!.component == spots[1].component)
      XCTAssertTrue(spots[1].compositeSpots[1].spot is Listable)
      XCTAssertEqual(spots[1].compositeSpots[1].spot.items.count, 11)
      XCTAssertEqual(spots[1].compositeSpots[1].spot.view.frame.size.height,
                     ((ItemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(spots[1].compositeSpots[1].spot.items.count))

      XCTAssertEqual(reloadTimes, 1)

      exception.fulfill()
    }
    waitForExpectations(timeout: 1.0, handler: nil)
  }

  func testReloadWithComponentsUsingCompositionTriggeringReloadLess() {
    let initialComponents: [Component] = [
      Component(kind: Component.Kind.grid.rawValue,
                span: 2.0,
                items: [
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      ),
      Component(kind: Component.Kind.grid.rawValue,
                span: 2.0,
                items: [
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      )
    ]

    let controller = Controller(spots: Parser.parse(initialComponents))
    controller.prepareController()
    controller.view.layoutIfNeeded()

    let spots = controller.spots

    XCTAssertEqual(spots.count, 2)

    var composite: Composable?
    var ItemConfigurable: ItemConfigurable?

    composite = spots[0].ui(at: 0)
    ItemConfigurable = spots[0].compositeSpots[0].spot.ui(at: 0)

    XCTAssertNotNil(composite)
    XCTAssertNotNil(ItemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spots[0].compositeSpots[0].parentSpot!.component == spots[0].component)
    XCTAssertTrue(spots[0].compositeSpots[0].spot is Listable)
    XCTAssertEqual(spots[0].compositeSpots[0].spot.items.count, 10)
    XCTAssertEqual(spots[0].compositeSpots[0].spot.view.frame.size.height,
                   (ItemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(spots[0].compositeSpots[0].spot.items.count))

    ItemConfigurable = spots[0].compositeSpots[1].spot.ui(at: 0)

    XCTAssertNotNil(ItemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spots[0].compositeSpots[1].parentSpot!.component == spots[0].component)
    XCTAssertTrue(spots[0].compositeSpots[1].spot is Listable)
    XCTAssertEqual(spots[0].compositeSpots[1].spot.items.count, 10)
    XCTAssertEqual(spots[0].compositeSpots[1].spot.view.frame.size.height,
                   (ItemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(spots[0].compositeSpots[1].spot.items.count))

    XCTAssertNotNil(composite)
    XCTAssertNotNil(ItemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spots[1].compositeSpots[0].parentSpot!.component == spots[1].component)
    XCTAssertTrue(spots[1].compositeSpots[0].spot is Listable)
    XCTAssertEqual(spots[1].compositeSpots[0].spot.items.count, 10)
    XCTAssertEqual(spots[1].compositeSpots[0].spot.view.frame.size.height,
                   (ItemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(spots[1].compositeSpots[0].spot.items.count))

    ItemConfigurable = spots[0].compositeSpots[1].spot.ui(at: 0)

    XCTAssertNotNil(ItemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spots[1].compositeSpots[1].parentSpot!.component == spots[1].component)
    XCTAssertTrue(spots[1].compositeSpots[1].spot is Listable)
    XCTAssertEqual(spots[1].compositeSpots[1].spot.items.count, 10)
    XCTAssertEqual(spots[1].compositeSpots[1].spot.view.frame.size.height,
                   (ItemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(spots[1].compositeSpots[1].spot.items.count))

    let newComponents: [Component] = [
      Component(kind: Component.Kind.grid.rawValue,
                span: 2.0,
                items: [
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.list.rawValue, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      )
    ]

    var exception: XCTestExpectation? = self.expectation(description: "Reload controller with components  triggering reloadLess")
    var reloadTimes: Int = 0

    controller.reloadIfNeeded(newComponents) {
      reloadTimes += 1

      let spots = controller.spots

      XCTAssertEqual(spots.count, 1)

      composite = spots[0].ui(at: 0)
      ItemConfigurable = spots[0].compositeSpots[0].spot.ui(at: 0)

      XCTAssertNotNil(composite)
      XCTAssertNotNil(ItemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(spots[0].compositeSpots[0].parentSpot!.component == spots[0].component)
      XCTAssertTrue(spots[0].compositeSpots[0].spot is Listable)
      XCTAssertEqual(spots[0].compositeSpots[0].spot.items.count, 10)
      XCTAssertEqual(spots[0].compositeSpots[0].spot.view.frame.size.height,
                     ((ItemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(spots[0].compositeSpots[0].spot.items.count))

      ItemConfigurable = spots[0].compositeSpots[1].spot.ui(at: 0)

      XCTAssertNotNil(ItemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(spots[0].compositeSpots[1].parentSpot!.component == spots[0].component)
      XCTAssertTrue(spots[0].compositeSpots[1].spot is Listable)
      XCTAssertEqual(spots[0].compositeSpots[1].spot.items.count, 10)
      XCTAssertEqual(spots[0].compositeSpots[1].spot.view.frame.size.height,
                     ((ItemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(spots[0].compositeSpots[1].spot.items.count))
      
      XCTAssertEqual(reloadTimes, 1)
      
      exception?.fulfill()
      exception = nil
    }
    waitForExpectations(timeout: 1.0, handler: nil)
  }
}
