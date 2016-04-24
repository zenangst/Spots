//
//  ViewController.swift
//  Dashboard
//
//  Created by Christoffer Winterkvist on 23/04/16.
//  Copyright © 2016 Hyper. All rights reserved.
//

import UIKit
import Spots
import Brick

class ViewController: SpotsController {

  convenience init(title: String) {
    let carouselItems = Component(items: [
      ViewModel(title: "UX", kind: Cell.Featured, meta: ["color" : UIColor.blackColor()]),
      ViewModel(title: "Persistency", kind: Cell.Featured, meta: ["color" : UIColor.grayColor()]),
      ViewModel(title: "Networking", kind: Cell.Featured, meta: ["color" : UIColor.greenColor()]),
      ViewModel(title: "Navigation", kind: Cell.Featured, meta: ["color" : UIColor.redColor()])
      ])

    let listItems = Component(title: "List Spot", items: [
      ViewModel(title: "Vadym Markov", subtitle: "iOS Developer", action: "1"),
      ViewModel(title: "Ramon Gilabert Llop", subtitle: "iOS Developer", action: "2"),
      ViewModel(title: "Khoa Pham", subtitle: "iOS Developer", action: "3"),
      ViewModel(title: "Christoffer Winterkvist", subtitle: "iOS Developer", action: "4")
      ], meta: ["headerHeight" : 44])

    let featuredOpensource = Component(span: 4, items: [
      ViewModel(title: "Whisper", kind: Cell.Featured, meta: ["color" : UIColor.blueColor()]),
      ViewModel(title: "Sync", kind: Cell.Featured, meta: ["color" : UIColor.orangeColor()]),
      ViewModel(title: "Presentation", kind: Cell.Featured, meta: ["color" : UIColor.yellowColor()]),
      ViewModel(title: "HUE", kind: Cell.Featured, meta: ["color" : UIColor.redColor()]),
      ])

    let gridItems = Component(span: 6, items: [
      ViewModel(title: "ImagePicker", kind: Cell.Featured, meta: ["color" : UIColor.darkGrayColor()]),
      ViewModel(title: "Sugar", kind: Cell.Featured, meta: ["color" : UIColor.redColor()]),
      ViewModel(title: "Cache", kind: Cell.Featured, meta: ["color" : UIColor.greenColor()]),
      ViewModel(title: "Spots", kind: Cell.Featured, meta: ["color" : UIColor.blackColor()]),
      ViewModel(title: "Compass", kind: Cell.Featured, meta: ["color" : UIColor.blueColor()]),
      ViewModel(title: "Pages", kind: Cell.Featured, meta: ["color" : UIColor.redColor()])
      ])

    let spots: [Spotable] = [
      ListSpot(component: Component(title: "Carousel Spot", meta: ["headerHeight" : 44])),
      CarouselSpot(carouselItems, top: 5, left: 0, bottom: 5, right: 0, itemSpacing: 0),
      ListSpot(component: Component(title: "Grid Spot", meta: ["headerHeight" : 44])),
      GridSpot(featuredOpensource, top: 10, left: 10, bottom: 20, right: 10, itemSpacing: -5),
      ListSpot(component: listItems),
      ListSpot(component: Component(title: "Grid Spot", meta: ["headerHeight" : 44])),
      GridSpot(gridItems, top: 10, left: 10, bottom: 20, right: 10, itemSpacing: -5),
      ]

    self.init(spots: spots)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

