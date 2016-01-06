![Spots logo](https://raw.githubusercontent.com/hyperoslo/Spots/master/Images/logo_v3.png)

[![CI Status](http://img.shields.io/travis/hyperoslo/Spots.svg?style=flat)](https://travis-ci.org/hyperoslo/Spots)
[![Version](https://img.shields.io/cocoapods/v/Spots.svg?style=flat)](http://cocoadocs.org/docsets/Spots)
[![License](https://img.shields.io/cocoapods/l/Spots.svg?style=flat)](http://cocoadocs.org/docsets/Spots)
[![Platform](https://img.shields.io/cocoapods/p/Spots.svg?style=flat)](http://cocoadocs.org/docsets/Spots)

## Table of Contents

* [Description](#description)
* [Key features](#key-features)
* [Usage](#usage)
* [SpotsController](#spotscontroller)
* [JSON structure](#json-structure)
* [Installation](#installation)
* [Author](#author)
* [Contributing](#contributing)
* [License](#license)

## Description

**Spots** is a view controller framework that makes your setup and future
development blazingly fast. Because of its internal architecture and
generic view models, you can easily move your view models into
the cloud. This is super easy to do because **Spots** can translate
JSON data into view model data right out-of-the-box.

## Key features

- JSON based views that could be served up by your backend.
- Supports displaying multiple collection and table views in the same container.
- Features both infinity scrolling and pull to refresh, all you have to do is to 
setup delegates that conforms to the public protocols on `SpotsController`.
- No need to implement your own data source, every `Spotable` object has their 
own set of `ListItem`’s.
which is maintained internally and is there at your disposable if you decide to 
make changes to them.
- Easy configuration of `UICollectionView`’s, `UITableView` and any custom spot 
implementation that you add. 
This improves code reuse and helps theme your app and ultimately to keep your 
application consistent.
- Support custom Spots, all you need to do is to conform to `Spotable`
- A rich public API for appending, prepending, inserting, updating or 
deleting `ListItems`.
- Features three different spots out-of-the-box; `CarouselSpot`, `GridSpot`, `ListSpot`
- Static custom cell registrations for all `Spotable` objects. 
Write one view cell and use it across your application, when and where you 
want to use it.
- Cell height caching, this improves performance as each cells has its height stored as a calculated value 
on the view model.
- Supports multiple cell types inside the same data source, no more ugly if-statements in your implementation;
**Spots** handles this for you by using a cell registry.

## Usage

### View models in the Cloud
```swift
let spots = Parser.parse(json)
let controller = SpotsController(spots: spots)
navigationController?.pushViewController(controller, animated: true)
```

The JSON data will be parsed into view model data and your view controller is ready to be presented, it is just that easy.

### Programmatic approach
```swift
let spots = [Spotable]()
let myContacts = Component(title: "My contacts", items: [
  ListItem(title: "John Hyperseed"),
  ListItem(title: "Vadym Markov"),
  ListItem(title: "Ramon Gilabert Llop"),
  ListItem(title: "Khoa Pham"),
  ListItem(title: "Christoffer Winterkvist")
])
let listSpot = ListSpot(component: myContacts)
let controller = SpotsController(spots: [listSpot])

navigationController?.pushViewController(controller, animated: true)
```

## SpotsController
The *SpotsController* inherits from *UIViewController* but it sports some core features that makes your everyday mundane tasks a thing of the past.

### Delegates
*SpotsController* has four different delegates

```swift
public protocol SpotsDelegate: class {
  func spotDidSelectItem(spot: Spotable, item: ListItem)
}
```

`spotDidSelectItem` is triggered when a user taps on an item inside of a `Spotable` object. It returns both the `spot` and the `item` to add context to what UI element was touched.

```swift
public protocol SpotsRefreshDelegate: class {
  func spotsDidReload(refreshControl: UIRefreshControl, completion: (() -> Void)?)
}
```

`spotsDidReload` is triggered when a user pulls the `SpotsScrollView` offset above its initial bounds.

```swift
public protocol SpotsScrollDelegate: class {
  func spotDidReachEnd(completion: (() -> Void)?)
}
```

`spotDidReachEnd` is triggered when the user scrolls to the end of the `SpotsScrollView`, this can be used to implement infinite scrolling.

```swift
public protocol SpotsCarouselScrollDelegate: class {
  func spotDidEndScrolling(spot: Spotable, item: ListItem)
}
```

`spotDidEndScrolling` is triggered when a user ends scrolling in a carousel, it returns item that is being displayed and the spot to give you the context that you need.

## Installation

**Spots** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Spots'
```

## Author

[Hyper](http://hyper.no) made this with ❤️. If you’re using this library we probably want to [hire you](https://github.com/hyperoslo/iOS-playbook/blob/master/HYPER_RECIPES.md)! Send us an email at ios@hyper.no.

## Contribute

We would love you to contribute to **Spots**, check the [CONTRIBUTING](https://github.com/hyperoslo/Spots/blob/master/CONTRIBUTING.md) file for more info.

## License

**Spots** is available under the MIT license. See the LICENSE file for more info.
