# Composition

A common problem when developing for Apple's platforms is that you often have to choose between which core framework component to base your foundation on. Depending on what you need then and there. This is a not a problem in itself, it becomes a problem when you need to iterate and combine two of them together, like displaying a collection view inside of a table view. This is where composition comes in. Spots supports composition out-of-the box and it is super easy to use and iterate on.

`Item`s inside of a `Component` have a property called `children`. In the case of Spots, children are `ComponentModel`'s that represent other `Component` objects. This means that you can easily add a grid, carousel or list inside any `Component` of your choice. On larger screens this becomes incredibly useful as composition can be used as a sane way of laying out your views on screen without the need for child view controllers, unmaintainable auto layout or frame based implementations.

You can create `Component` pseudo objects that handle layout, this is especially useful for `Component`'s that use a grid-based layout, where you can use the layout to use `span` to define how many objects should be displayed side-by-side.

Composition is supported on iOS, tvOS and macOS.
