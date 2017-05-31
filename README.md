![Spots logo](https://raw.githubusercontent.com/hyperoslo/Spots/master/Images/cover_v6.jpg)
<div align="center">
<a href="https://travis-ci.org/hyperoslo/Spots" target="_blank">
<img src="http://img.shields.io/travis/hyperoslo/Spots.svg?style=flat">
</a>

<a href="http://cocoadocs.org/docsets/Spots" target="_blank">
<img src="https://img.shields.io/cocoapods/v/Spots.svg?style=flat">
</a>

<a href="https://github.com/Carthage/Carthage" target="_blank">
<img src="https://img.shields.io/badge/Carthage-Compatible-brightgreen.svg?style=flat">
</a>

<a href="http://cocoadocs.org/docsets/Spots" target="_blank">
<img src="https://img.shields.io/cocoapods/l/Spots.svg?style=flat">
</a>

<a href="http://cocoadocs.org/docsets/Spots" target="_blank">
<img src="https://img.shields.io/badge/platform-ios | macos | tvos-lightgrey.svg">
</a>
<br/>
<a href="http://cocoadocs.org/docsets/Spots" target="_blank">
<img src="https://img.shields.io/cocoapods/metrics/doc-percent/Spots.svg?style=flat">
</a>

<a href="https://codecov.io/github/hyperoslo/Spots?branch=master"><img src="https://codecov.io/github/hyperoslo/Spots/coverage.svg?branch=master" alt="Coverage Status" data-canonical-src="https://codecov.io/github/hyperoslo/Spots/coverage.svg?branch=master" style="max-width:100%;"></a>

<img src="https://img.shields.io/badge/%20in-swift%203.0-orange.svg">

<a href="https://gitter.im/hyperoslo/Spots?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge">
<img src="https://badges.gitter.im/hyperoslo/Spots.svg">
</a>
<br><br>
</div>

**Spots** is a cross-platform view controller framework for building component-based UIs. The internal architecture is built using generic view models that can be transformed both to and from JSON. So, moving your UI declaration to a backend is as easy as pie.
Data source and delegate setup is handled by **Spots**, so there is no need for you to do that manually. The public API is jam-packed with convenience methods for performing mutation, it is as easy as working with a regular collection type.

## Table of Contents

<img src="https://raw.githubusercontent.com/hyperoslo/Spots/master/Images/icon_v5.png" alt="Spots Icon" align="right" />

* [Getting started with Spots](#getting-started-with-spots)
* [Origin Story](#origin-story)
* [Universal support](#universal-support)
* [Usage](#usage)
* [Key features](#key-features)
* [Programmatic approach](#programmatic-approach)
* [The many faces of Spots](#the-many-faces-of-components)
* [Installation](#installation)
* [Dependencies](#dependencies)
* [Author](#author)
* [Credits](#credits)
* [Contributing](#contributing)
* [License](#license)

## Getting started with Spots

If you are looking for a way to get started with `Spots`, we recommend taking a look at our [Getting started guide](https://github.com/hyperoslo/Spots/blob/master/Documentation/Getting%20started%20guide.md).

## Origin Story

We wrote a Medium article about how and why we built `Spots`.
You can find it here: [Hitting the sweet spot of inspiration](https://medium.com/@zenangst/hitting-the-sweet-spot-of-inspiration-637d387bc629#.b9a1mun2i)

## Universal support

Apple's definition of a universal applications is iPhone and iPad. Spots takes this a step further with one controller tailored to each platform to support all your UI related update needs. Internally, everything conforms to the same shared protocol. What this means for you, is that get a unified experience when developing for iOS, tvOS or macOS.

## Usage

Use the following links to dive a bit deeper into how Spots works.

* [Building views in Spots](https://github.com/hyperoslo/Spots/blob/master/Documentation/Building%20views%20in%20Spots.md)
* [Caching](https://github.com/hyperoslo/Spots/blob/master/Documentation/Caching.md)
* [Composition](https://github.com/hyperoslo/Spots/blob/master/Documentation/Composition.md)
* [Delegates](https://github.com/hyperoslo/Spots/blob/master/Documentation/Delegates.md)
* [Live Editing](https://github.com/hyperoslo/Spots/blob/master/Documentation/Live%20Editing.md)
* [JSON Structure](https://github.com/hyperoslo/Spots/blob/master/Documentation/JSON%20Structure.md)
* [Models](https://github.com/hyperoslo/Spots/blob/master/Documentation/Models.md)
* [Performing mutation](https://github.com/hyperoslo/Spots/blob/master/Documentation/Performing%20mutation.md)
* [Working with layout](https://github.com/hyperoslo/Spots/blob/master/Documentation/Layout.md)
* [Working with the SpotsController](https://github.com/hyperoslo/Spots/blob/master/Documentation/SpotsController.md)


## How does it work?

At the top level of **Spots**, you have the **SpotsController** which is the replacement for your view controller.

Inside of the **SpotsController**, you have a **SpotsScrollView** that handles the linear layout of the components that you add to your data source. It is also in charge of giving the user a unified scrolling experience. Scrolling is disabled on all underlaying components except for components that have horizontal scrolling.

So how does scrolling work? Whenever a user scrolls, the **SpotsScrollView** computes the offset and size of its children. By using this technique you can easily create screens that contain lists, grids and carousels with a scrolling experience as smooth as proverbial butter. By dynamically changing the size and offset of the children, **SpotsScrollView** also ensures that reusable views are allocated and deallocated like you would expect them to.
**SpotsScrollView** uses KVO on any view that gets added so if one component changes height or position, the entire layout will invalidate itself and redraw it like it was intended.

**SpotsController** supports multiple **Component**'s, each represent their own UI container and hold their own data source. Components all share the same data model called `ComponentModel`, it includes layout, interaction and view model data. **Component** gets its super-powers from protocol extensions, powers like mutation, layout processing and convenience methods for accessing model information. 

## Key features

- JSON based views that could be served up by your backend.
- Live editing.
- View based caching for controllers, table and collection views.
- Supports displaying multiple collections, tables and regular views in the same container.
- Features both infinity scrolling and pull to refresh (on iOS), all you have to do is to
setup delegates that conform to the public protocols on `SpotsController`.
- No need to implement your own data source, every `Component` has its
own set of `Item`’s.
which is maintained internally and is there at your disposable if you decide to
make changes to them.
- Easy configuration for registering views.
This improves code reuse and helps to theme your app and ultimately keep your application consistent.
- A rich public API for appending, prepending, inserting, updating or
deleting `Item`s.
- Has built-in support for regular views inside of both collection and table views.
Write one view and use it across your application, when and where you want to use it.
- Supports view states such as normal, highlighted and selected.
- View height caching that improves performance as each view has its height stored as a calculated value.
on the view model.
- Supports multiple views inside the same data source, no more ugly if-statements in your implementation;
- Soft & hard updates to UI components.
- Supports both views made programmatically and nib-based views.
**Spots** handles this for you by using a view registry.

## Installation

**Spots** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Spots'
```

**Spots** is also available through [Carthage](https://github.com/Carthage/Carthage). To install it, add the following to your `Cartfile`:

```ruby
github "hyperoslo/Spots"
```

## Changelog

Looking for a change log? You can find it [here](https://github.com/hyperoslo/Spots/blob/master/CHANGELOG.md)

## Dependencies

- **[Cache](https://github.com/hyperoslo/Cache)**
Used for `ComponentModel` and `Item` caching when initializing a `SpotsController` or `CoreComponent` object with a cache key.
- **[Tailor](https://github.com/zenangst/Tailor)**
To seamlessly map JSON to both `ComponentModel` and `Item`.

## Author

[Hyper](http://hyper.no) made this with ❤️. If you’re using this library we probably want to [hire you](https://github.com/hyperoslo/iOS-playbook/blob/master/HYPER_RECIPES.md)! Send us an email at ios@hyper.no.

## Contribute

We would love you to contribute to **Spots**, check the [CONTRIBUTING](https://github.com/hyperoslo/Spots/blob/master/CONTRIBUTING.md) file for more info.

## Credits

- The idea behind Spot came from [John Sundell](https://github.com/johnsundell)'s tech talk "ComponentModels & View Models in the Cloud - how Spotify builds native, dynamic UIs".
- [Ole Begemanns](https://github.com/ole/) implementation of [OLEContainerScrollView](https://github.com/ole/OLEContainerScrollView) is the basis for `SpotsScrollView`, we salute you.
Reference: http://oleb.net/blog/2014/05/scrollviews-inside-scrollviews/

## License

**Spots** is available under the MIT license. See the LICENSE file for more info.
