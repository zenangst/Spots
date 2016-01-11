//: Playground - noun: a place where people can play

import UIKit
import Spots

let myContacts = Component(title: "My contacts", items: [
  ListItem(title: "John Hyperseed", subtitle: "Build server"),
  ListItem(title: "Vadym Markov", subtitle: "iOS Developer"),
  ListItem(title: "Ramon Gilabert Llop", subtitle: "iOS Developer"),
  ListItem(title: "Khoa Pham", subtitle: "iOS Developer"),
  ListItem(title: "Christoffer Winterkvist", subtitle: "iOS Developer")
  ])
let listSpot = ListSpot(component: myContacts)
let controller = SpotsController(spots: [listSpot])
controller.view
