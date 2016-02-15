//: Playground - noun: a place where people can play

import UIKit
import Spots

let myContacts = Component(title: "My contacts", items: [
  ViewModel(title: "John Hyperseed", subtitle: "Build server"),
  ViewModel(title: "Vadym Markov", subtitle: "iOS Developer"),
  ViewModel(title: "Ramon Gilabert Llop", subtitle: "iOS Developer"),
  ViewModel(title: "Khoa Pham", subtitle: "iOS Developer"),
  ViewModel(title: "Christoffer Winterkvist", subtitle: "iOS Developer")
  ])
let listSpot = ListSpot(component: myContacts)
let controller = SpotsController(spots: [listSpot])
controller.view
