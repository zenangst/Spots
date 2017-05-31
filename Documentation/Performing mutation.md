# Performing mutation

It is very common that you need to modify your data source and tell your UI component to either insert, update or delete depending on the action that you performed. This process can be cumbersome, so to help you out, **Spots** has some great convenience methods to help you with this process.

On **SpotsController** you have simple methods like `reload(withAnimation, completion)` that tells all components to reload.

You can reload **SpotsController** using a collection of **ComponentModel**’s. Internally it will perform a diffing process to pinpoint what changed, in this process it cascades down from component level to item level, and checks all the moving parts, to perform the most appropriate update operation depending on the change. At item level, it will check if the items size changed, if not it will scale down to only run the `configure` method on the view that was affected. This is what we call hard and soft updates, it will reduce the amount of *blinking* that you can normally see in iOS.

A **SpotsController** can also be reloaded using JSON. It behaves a bit differently than `reloadIfNeeded(components)` as it will create new components and diff them towards each other to find out if something changed. If something changed, it will simply replace the old objects with the new ones.

The difference between `reload` and `reloadIfNeeded` methods is that they will only run if change is needed, just like the naming implies.

If you need more fine-grained control by pinpointing an individual component, we got you covered on this as well. **SpotsController** has an update method that takes the component index as its first argument, followed by an animation label to specify which animation to use when doing the update.
The remaining arguments are one mutation closure where you get the component and can perform your updates, and finally one completion closure that will run when your update is performed both on the data source and the UI component.
This method has a corresponding method called `updateIfNeeded`, which applies the update if needed.

You can also `append` `prepend`, `insert`, `update` or `delete` with a series to similar methods that are publicly available on **SpotsController**.

All methods take an `Item` as their first argument, the second is the index of the component that you want to update. Just like `reload` and `update`, it also has an animation label to give you control over what animation should be used. As an added bonus, these methods also work with multiple items, so instead of passing just one item, you can pass a collection of items that you want to `append`, `prepend` etc.
