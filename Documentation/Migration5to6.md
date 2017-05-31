# Changes between 5.8.x and 6.0.0

### tl;dr

* Bug fixes and improvements 🤓

### Summary

A lot has changed in 6.0.0, to affectedly move forward we had to break things. 
Here is a summary of what we changed.

* One of the biggest improvements that we have done in `6.x.x` is that your views no longer have to inherit from the UI component that you decide to use. This means that your views can be in both `UITableView` and `UICollectionView` without having to provide two versions on the same view with different inheritance. This is now handled internally by wrapping your view in either a `GridWrapper` or `ListWrapper`. This is totally transparent for you when working with views in your app. 

* To avoid confusion between what is a model and UI containers, `Component` has now been renamed to `ComponentModel`.

* To normalize naming through out the framework we decided to use a different naming convention so ease the adoption of Spots. We got rid of protocols like `Spotable`, `Gridable` and `Listable`. The core types like `ListSpot`, `GridSpot` etc has also been removed. Instead we now use `Component` which is a polymorphic class that configures itself to reflect the same kind of UX has the previous core types had.

* `Controller` is now called `SpotsController` to better reflect where the class comes from, it will also reduce the amount of times that you have to reference the framework using the module namespace in your implementations.

* `SpotsDelegate` has been changed and renamed to `ComponentDelegate`.
The methods look slightly different than they did in 5.x.
Instead of having delegates method that look like this:

```swift
func didSelect(item: Item, in spot: Spotable)
```

They now start with a prefix to increase discoverability.

```swift
func component(_ component: Component, itemSelected item: Item)
```

* Look up `ComponentDelegate` for more information about what the new
delegate methods look like.

* `SpotConfigurable` is replaced by `ItemConfigurable`. We no longer have a `preferredViewSize` property, that has been replaced by a method called `computeSize(for item: Item)`.

* The configuration method has also changed, instead of using `inout` it now receives a constant. The new method looks like this:

```swift
func configure(with item: Item)
```

* Headers and footers no longer rely on `Componentable`, instead they share the same protocol as items, namely `ItemConfigurable`.

* `Brick` is no longer a dependency in `Spots`. `Item` now comes bundled which means that you have to import one less framework.

* Registering views are no longer done on the core types (as they have been removed). You now register views on `Configuration` which is a new class introduced in `6.0.0`.

* Meta properties that previously lived on the `Spotable` objects were never ported over to `Component`. Instead it uses `Layout` to configure the look and feel of the `Component`. `Layout` is a property on `ComponentModel`.

* Bundled views like `CarouselSpotCell`, `GridSpotCell`, `GridSpotItem` have been removed. The only bundled view that ships with Spots is `DefaultItemView`.

* Support for custom collection view layout have been removed.

* `SpotFactory` has been removed as we no longer need to create different types of `Spotable` objects. The parser remains intact.

* Views in Spots now support `ViewState` so that you view can configure itself to reflect the current selection or highlighted state of the `Component`.

* `Composable` has been removed. This is now handled with `CompositeComponent`.

* `GridableLayout` has been renamed to `ComponentFlowLayout`.

* `render()` on `Component` is no longer a method but a property called `view`.

* `.spots` on `SpotsController` has been renamed to `.components`.

We have come a long way and a lot of work went into making 6.0.0.
If dare to look into everything that changed, you can use this diff.
It is quiet large so you have been warned, happy migration.

https://github.com/hyperoslo/Spots/compare/5.8.3...master
